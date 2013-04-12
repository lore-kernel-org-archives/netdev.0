From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 02/11] ixgbe: Mask off check of frag_off as we only
 want fragment offset
Date: Fri, 12 Apr 2013 13:12:31 -0700
Message-ID: <51686AAF.4090105@intel.com>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>    <1365765866-15741-3-git-send-email-jeffrey.t.kirsher@intel.com>    <1365773328.4459.19.camel@edumazet-glaptop>   <1365774332.4459.24.camel@edumazet-glaptop> <51683884.2010509@intel.com>  <1365785511.4459.46.camel@edumazet-glaptop> <516850E4.8020504@intel.com> <1365792277.4459.67.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43829 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755519Ab3DLUMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 16:12:55 -0400
In-Reply-To: <1365792277.4459.67.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2013 11:44 AM, Eric Dumazet wrote:
> On Fri, 2013-04-12 at 11:22 -0700, Alexander Duyck wrote:
>>   If it could get broken up somehow so that it, or at
>> least pieces of it could just be used on linear blocks of data then I
>> might be more interested in reusing it.
> But this is not going to happen. Our skb code is able to deal with
> multiple areas (skb->head and frags). We are not going to duplicate it
> for linear skbs 'only'
>
> Thats your call obviously to maintain your own code, but consider you
> fix this quite incredible bug only now. (All TCP data segments have the
> DF flag set, so you were not pulling tcp headers)

I think part of the trouble is we are debating reworking the wrong
function.  We would probably be better off if we could come up with a
generic way to handle the ixgbe_pull_tail function.  I think the only
complaint I would have in using the __skb_get_poff in there is the fact
that it would be copying the header in multiple chunks.  If it worked
more like GRO where it just used an offset in the first frag instead of
having to copy the headers separately to read them then I would be 100%
on board.

Thanks,

Alex
