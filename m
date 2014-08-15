From: Stephane Chazelas <stephane.chazelas@gmail.com>
Subject: Re: network interfaces called "all", "default" or "config"
Date: Fri, 15 Aug 2014 09:33:51 +0100
Message-ID: <CACsCDONU9Zq902rj6aJXGZGnPfAWbxsiFe9mMS8usyyUdTYa9A@mail.gmail.com>
References: <20140723113314.GA7798@chaz.gmail.com>
	<53CFCD26.1020409@infradead.org>
	<CACsCDOP8DOnB0zZtT_WLhiBXjxXh1aH1eGF9_h0dRN1i9YDU-A@mail.gmail.com>
	<CAHA+R7MLQtYF5vBN0D66Wk8iyGZABf5=Az293gUH6w=4THv8Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Randy Dunlap <rdunlap@infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7MLQtYF5vBN0D66Wk8iyGZABf5=Az293gUH6w=4THv8Gw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, I know  those are also used for the eth0:1 "aliases", but the bug
is, since it is allowed to do

    ip link add link eth0 eth0:123 type vlan id 123

Then the

    ip link del link eth0 eth0:123

should be allowed as well. Or probably better to avoid confusion

    ip link add link eth0 foo:bar type vlan id 123

should not be allowed.

Worse:

   ip link add link eth0 foo:bar type vlan id 1
   ip link add link eth0 foo type vlan id 2

   ip link del foo:bar

deletes foo instead of foo:bar.



On 14 August 2014 19:37, Cong Wang <cwang@twopensource.com> wrote:
> On Thu, Aug 14, 2014 at 2:41 AM, Stephane Chazelas
> <stephane.chazelas@gmail.com> wrote:
>> By the way, this is related:
>>
>> $ ip link add link eth0 eth0:123 type vlan id 123
>> $ ip link del link eth0 eth0:123
>> RTNETLINK answers: Operation not supported
>
> Kernel reads "eth0:123" as an alias of "eth0", so it will just
> truncate the dev name into "eth0":
>
>
>         ifr.ifr_name[IFNAMSIZ-1] = 0;
>
>         colon = strchr(ifr.ifr_name, ':');
>         if (colon)
>                 *colon = 0;
