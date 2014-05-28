From: Milos Vyletel <milos.vyletel@gmail.com>
Subject: Re: [patch net-next] net: ipv6: trigger action when setting conf.all sysctls
Date: Wed, 28 May 2014 13:45:52 -0400
Message-ID: <CAAFXRd2xhSa_X2u-dCB_nM==_vLoV_GypNPzMugW=njBbnLr6g@mail.gmail.com>
References: <1400519372-5703-1-git-send-email-milos.vyletel@gmail.com>
	<CAHA+R7PaM4c6TmUtTLDAGnBUmRKE7=vnsjm67i=rmNebZvacVw@mail.gmail.com>
	<20140521.163113.383854871907102866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: cwang@twopensource.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	"open list:X86 ARCHITECTURE..." <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140521.163113.383854871907102866.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 21, 2014 at 4:31 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <cwang@twopensource.com>
> Date: Wed, 21 May 2014 10:35:17 -0700
>
>> On Mon, May 19, 2014 at 10:09 AM, Milos Vyletel <milos.vyletel@gmail.com> wrote:
>>> As it is right now most of these tunables don't do anything - they don't
>>> set any interface specific settings to the desired value and they don't
>>> take precedence before device specific settings in most cases.
>>>
>>> Documentation/networking/ip-sysctl.txt defines them to be:
>>> conf/all/*:
>>>         Change all the interface-specific settings.
>>>
>>> but that is not really the case.
>>>
>>
>> I don't think it's a good idea, it enforces interface specific changes.
>>
>> You need to mimic what IPv4 conf does (if it hasn't done yet), something
>> like below:
>>
>> #define IN_DEV_MAXCONF(in_dev, attr) \
>>         (max(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), attr), \
>>              IN_DEV_CONF_GET((in_dev), attr)))
>
> Agreed.

Thanks for the comments guys. I've looked at ipv4 sysctl code and I'm going to
align ipv6 code and add similar macros (IN6_DEV_{OR,MAX,AND}CONF).

Milos
