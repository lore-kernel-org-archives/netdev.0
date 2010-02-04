From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter/iptables and network interface names
Date: Thu, 04 Feb 2010 15:55:55 +0100
Message-ID: <4B6ADFFB.4050407@trash.net>
References: <4B6AC467.7020209@redhat.com> <alpine.LSU.2.01.1002041528300.13435@obet.zrqbmnf.qr> <4B6ADA3A.7040201@trash.net> <alpine.LSU.2.01.1002041542150.13435@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Woerner <twoerner@redhat.com>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1002041542150.13435@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Thursday 2010-02-04 15:31, Patrick McHardy wrote:
>> Jan Engelhardt wrote:
>>> On Thursday 2010-02-04 13:58, Thomas Woerner wrote:
>>>
>>>> I think there should be some discussion about interface names and
>>>> limits in kernel and netfilter/iptables.
>>>>
>>>> What do you think?
> 
> When was the last time you needed a control character in your
> interface name?

Actually I did use ansi-colors in my interface names once for fun :)

Anyways, I don't see why iptables should impose arbitrary restrictions.

>>> I think we should cc netdev for a start.
>> I don't think there is a reason for this limitation in iptables,
>> so why not simply remove it?
> 
> Like this?
> 
> @@ -473,12 +473,11 @@ void xtables_parse_interface(const char *arg, char *vianame,
>  		memset(mask, 0xFF, vialen + 1);
>  		memset(mask + vialen + 1, 0, IFNAMSIZ - vialen - 1);
>  		for (i = 0; vianame[i]; i++) {
> -			if (vianame[i] == ':' ||
> -			    vianame[i] == '!' ||
> -			    vianame[i] == '*') {
> +			if (vianame[i] == '/' ||
> +			    vianame[i] == ' ') {
>  				fprintf(stderr,
>  					"Warning: weird character in interface"
> -					" `%s' (No aliases, :, ! or *).\n",
> +					" `%s' ('/' and ' ' are not allowed by the kernel).\n",
>  					vianame);

The kernel also forbids ".".
