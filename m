From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH (resend)][EBTABLES]: Fix alignment checks in ebt_among.ko
 module.
Date: Fri, 29 Feb 2008 13:48:49 +0100
Message-ID: <47C7FF31.1060108@trash.net>
References: <47C7C23C.2050100@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Bart De Schuymer <bdschuym@pandora.be>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47C7C23C.2050100@openvz.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> I've sent this patch some days ago to Bart, but with no answer...
> 
> When trying to do
> 
> 	# ebtables -A FORWARD --among-src 0:12:34:56:78:9a=192.168.0.10 -j ACCEPT
> 
> on x86_64 box the ebt_among->check() callback warns me that
> 
> 	ebtables: among: wrong size: 1060 against expected 1056, rounded to 1056
> 
> Checking the ebtables sources, I found that the alignment is done
> differently in the tool and the kernel. Tool makes it like this:
> 
> 	EBT_ALIGN(sizeof(struct ebt_among_info)) + X
> 
> while the kernel module like this:
> 
> 	EBT_ALIGN(sizeof(struct ebt_among_info) + X)
> 
> So the suggested fix is to move the alignment in the kernel. After
> the fix the rule is added and appears in the ebtables -L output.


It seems the kernel is correct and userspace is doing it
wrong, so I think userspace should be fixed instead.
The problem with your patch is that is causes misalignment
for following structures that contain u64 members.


