From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH] netfilter/nflog: nflog-range does not truncate packets
Date: Fri, 17 Jun 2016 11:43:35 -0400
Message-ID: <57641AA7.70709@akamai.com>
References: <20160602002354.GG1644@akamai.com> <20160606223106.GA1621@salvia>
 <57575367.4010604@akamai.com> <20160608121625.GA4097@salvia>
 <5759AE1B.2080500@akamai.com> <575E2B49.7090809@akamai.com>
 <20160615123945.GA3594@salvia> <57616C49.7090403@akamai.com>
 <c7780b528f80417bbac319767a2ecf65@usma1ex-dag1mb5.msg.corp.akamai.com>
 <20160617112219.GA3395@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "Lubashev, Igor" <ilubashe@akamai.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"kadlec@blackhole.kfki.hu" <kadlec@blackhole.kfki.hu>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"Hunt, Joshua" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pai.vishwain@gmail.com" <pai.vishwain@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160617112219.GA3395@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/17/2016 07:22 AM, Pablo Neira Ayuso wrote:
> On Wed, Jun 15, 2016 at 03:13:15PM +0000, Lubashev, Igor wrote:
>> Vish, Pablo,
>>
>> I wonder about the value of sending more data than a client is
>> willing to consume (setting aside the important fact that the client
>> code crashes due to the extra data).
>>
>> It seems that we should either drop the nflog-range parameter from
>> nflog altogether (and just use the len from the client) or allow
>> nflog-range to further *restrict* the number of bytes sent to the
>> client.
>>
>> The "further restrict" logic would make it easier to build iptables
>> rules that vary nflog-range based on some match conditions, so a
>> single client would get different packet length depending on what
>> rules matched.
> 
> Now I understand your usecase. Restricting the size based on match
> conditions sound reasonable to me.
> 
> Why don't you add a new userspace option, eg. --nflog-size, that
> specifies this "further restrict" logic?
> 
> What I'm proposing is:
> 
> 1) If --nflog-range is used, print a message telling: "--nflog-range
>    has never worked, ignoring this option."
> 
> 2) If --nflog-size is used, set the size in the structure that is
>    passed to the kernel, and apply this "further restrict" logic.
> 
> 3) Add the flag to the kernel that I suggested. This flag is only set
>    via --nflog-size.
> 
> Just to clarify: What I'm trying to avoid is breaking the thing for
> users that are using this --nflog-range (even if it doesn't work) and
> then change the behaviour for them.
> 
> With the new option, we really validate that the user is exactly
> asking for this "further restrict" logic that you need.
> 
> let me know, thanks.
> 

Sounds good to me, yes it will definitely change the behavior for users
who are using that parameter (whether intentional or not). I'm OK with
adding a new parameter instead of using --nflog-range. I will send a
patch with these changes.
