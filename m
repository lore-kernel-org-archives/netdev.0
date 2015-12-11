From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFCv3 bluetooth-next 4/4] 6lowpan: iphc: add support for
 stateful compression
Date: Fri, 11 Dec 2015 18:13:53 +0100
Message-ID: <20151211171352.GA25972@omega>
References: <1448796882-316-1-git-send-email-alex.aring@gmail.com>
 <1448796882-316-5-git-send-email-alex.aring@gmail.com>
 <20151211170541.GA1119@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, lukasz.duda-hR+23Fw+YnFSHonuZl5R5Q@public.gmane.org,
	martin.gergeleit-6wGqcYweBVc@public.gmane.org
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151211170541.GA1119@omega>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 11, 2015 at 06:05:41PM +0100, Alexander Aring wrote:
> Hi,
> 
> status update here.
> 
> I implemented successful basic 6CO RA messages at sending and
> processing inside radvd.
> 
> There might also the question if processing 6CO inside kernel or
> userspace? I put the basic functionality inside userspace for now.
> 
> I will send patches for this in the next days.
> 
> Anyway I figured some things out which was completely wrong inside this
> patch.
> 
>  - There exist one context based table only.
>    
>    In rfc6282 stands:
>    The specification enables a node to use up to 16 contexts. The
>    context used to encode the source address does not have to be the
>    same as the context used to encode the destination address.
> 
>    and I thought it was $SOME_TABLE[DCI] != $DIFFERENT_TABLE[SCI].

in case of SCI == DCI.

>    But it means in general simple that it can be: DCI != SCI.
> 
>    With this knowledge the code gets much smaller.
> 
>  - I also remove the validation check for contexts, it can be any
>    prefic/address. The lookup functionality will deal with that if the
>    context looks not correct or need additional changes.
> 

  - Also I renamed the "enabled" to "C" which is the compression flag of
    6CO.

- Alex
