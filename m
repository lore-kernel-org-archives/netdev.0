From: rsa <ravi.mlists@gmail.com>
Subject: Re: switching network namespace midway
Date: Thu, 25 Oct 2012 11:12:58 -0400
Message-ID: <CAFaHj6HxV=YgZiUp-WkuGVJBa2nv-g86yUaa_9XxnhqTex=zOg@mail.gmail.com>
References: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com>
	<878vavshhp.fsf@xmission.com>
	<20121024212116.GG15034@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:50421 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935801Ab2JYPNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 11:13:00 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so1405291wgb.1
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 08:12:58 -0700 (PDT)
In-Reply-To: <20121024212116.GG15034@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Eric.  That makes sense. I can remember both network namespaces
and switch to the other prior to route lookup if necessary.
Any gotchas on receiving tunneled packed on the tunnel interface?  Looking at
the code there is no change necessary.  Packet arrives on tunnel
interface which is
decapsulated and given to net_if_rx() for inner packet processing.  Am I mssing
something?

thank you
rsa

On Wed, Oct 24, 2012 at 5:21 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
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
>
>                 -ben
