From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: switching network namespace midway
Date: Wed, 24 Oct 2012 18:37:16 -0700
Message-ID: <87ip9zqqlv.fsf@xmission.com>
References: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com>
	<878vavshhp.fsf@xmission.com> <20121024212116.GG15034@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: rsa <ravi.mlists@gmail.com>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34715 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243Ab2JYBh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 21:37:26 -0400
In-Reply-To: <20121024212116.GG15034@kvack.org> (Benjamin LaHaise's message of
	"Wed, 24 Oct 2012 17:21:16 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise <bcrl@kvack.org> writes:

> On Wed, Oct 24, 2012 at 02:11:14PM -0700, Eric W. Biederman wrote:
>> rsa <ravi.mlists@gmail.com> writes:
>> 
>> > Assuming I have a tunnel interface where two route lookups are done --
>> > one for innter
>> > packet and the other for outer -- do you see any issues in switching
>> > the network
>> > namespace prior to second route lookup (and restore to the original namespace
>> > after the second lookup is done)?
>> >
>> > If so, are there any other calls other than sk_change_net() needed?
>> 
>> In general sk_change_net is a bad idea.
>> 
>> Most likely what you want to do is simply memorize both struct net's
>> that you care about and perform the routing lookup as appropriate.
>> 
>> Certainly you don't want to be calling sk_change_net for every packet
>> that goes through your tunnel.
>
> I've actually done this with L2TP.  The packets coming into the system from 
> the tunnel are received on one UDP socket in one "struct net", but the 
> decapsulated packets are received on a "struct net_device" that is in a 
> different "struct net".  No special coding is required -- just move the 
> tunnel's net_device into another namespace after creation and it works as 
> expected.  Using sk_change_net() would be full of races and is really not 
> required for the vast majority of use cases.

Yes.  Although L2TP is not an example of code I would copy.  Any other
tunnel would be better.  I haven't looked closely at L2TP but it keeps
popping up as a poster child for small little network namespace bugs
that I don't want to think about.

Last I looked to use L2TP it required a magic userspace that I couldn't
find and I haven't cared enough to write.  Ben would you be interested
in helping flush out the network namespace bugs out of L2TP?

Eric
