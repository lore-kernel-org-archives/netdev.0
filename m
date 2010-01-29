From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Thu, 28 Jan 2010 19:05:19 -0500
Message-ID: <4B62263F.9000508@majjas.com>
References: <4B60707F.1000608@majjas.com> <20100127095614.14313677@nehalam>
 <4B608128.7090607@majjas.com> <4B6089C7.4010803@majjas.com>
 <4B61ADF1.7060705@majjas.com> <4B61BEA4.1030905@majjas.com>
 <20100128090835.0d93e53a@nehalam> <4B61DB79.4080703@majjas.com>
 <20100128223447.GC3109@del.dom.local> <4B621316.8070308@majjas.com>
 <20100128225621.GD3109@del.dom.local> <4B6216B9.1010802@majjas.com>
 <20100128153643.0fca3c51@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932312Ab0A2AFN@vger.kernel.org>
In-reply-to: <20100128153643.0fca3c51@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/28/2010 6:36 PM, Stephen Hemminger wrote:
> Please try this patch (and only this patch), on 2.6.33-rc5[*];
> none of the other patches that did not make it upstream because that
> confuses things too much.
>
> The code that checks for DMA mapping errors on receive buffers would
> not handle errors correctly.  I doubt you have these errors, but if you
> did then it would explain the problems.  The code has to be a little
> tricky and build mapping for new rx buffer before releasing old one,
> that way if new mapping fails, the old one can be reused.
>
> If it works for you, I will resubmit with signed-off.
>
> ---
> * If you want to use DMA debugging, then you will also need the match patch.
>    
Ok - I'll also be running with the recent sched fork vs. hotplug vs. 
cpuset namespaces patch (commit 
fabf318e5e4bda0aca2b0d617b191884fda62703) from tip. Without that I get 
an rcu hang.

My plan then is to run with your patch, the rcu patch & the dma debug 
patch, but disable dma debug for now and see of the problem recurs. If 
it works, I'll know in a couple of days. If not, perhaps sooner :(.
