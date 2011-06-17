From: Dominique Martinet <rnfhrznznaq.tf@noclue.notk.org>
Subject: Re: bnx2 vlan issue
Date: Fri, 17 Jun 2011 06:10:24 +0000 (UTC)
Message-ID: <loom.20110617T075702-107@post.gmane.org>
References: <AANLkTik0BOuDj5wmfHabZx_OzXDROtDLR2qtqUqQu4ko@mail.gmail.com> <AANLkTi=rOjHZt_F01UfunrTm=2r1BO5QGFDeV9XyKX4G@mail.gmail.com> <AANLkTimAnHcoVDY_p8PqZLMJdMz2w7bMnSbOwzn4aR4i@mail.gmail.com> <AANLkTimJsBYefz3+3HgBgrHUR33g+TWuBp15E=VODohb@mail.gmail.com> <AANLkTik1JJO7mqxPzqfshMfH2JFUXn+yxbTqVdr4QDf6@mail.gmail.com> <AANLkTi=7ETnRWOLRVAWhv=3BHZdzUnLvAqzxXOz399Xx@mail.gmail.com> <AANLkTi=D9Qw+Tw7wHb2T7UG_o9zkZcr2meHE3fwcMwvF@mail.gmail.com> <AANLkTimnKRDY8QLiJMMLqNzCA_-6UJmUDHKf-i1Yt3V5@mail.gmail.com> <AANLkTi=zfhwHTB7kitgwk3AzSa0aFFyxgM_ZY-3wObR5@mail.gmail.com> <AANLkTi=gsP3ZZyEwO+CcM3uB6G5-QswYEfqdtiy8oOyv@mail.gmail.com> <AANLkTi=CaWMSmRsN8SXfn999=4RNnFESTLjyBytYVzR2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:39961 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603Ab1FQGPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 02:15:10 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QXSKh-0000Ks-PU
	for netdev@vger.kernel.org; Fri, 17 Jun 2011 08:15:09 +0200
Received: from nobunaga.t.u-tokyo.ac.jp ([157.82.13.93])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 08:15:07 +0200
Received: from rnfhrznznaq.tf by nobunaga.t.u-tokyo.ac.jp with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 08:15:07 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Jesse Gross <jesse <at> nicira.com> writes:
> On Thu, Mar 24, 2011 at 5:26 PM, Seblu <seblu <at> seblu.net> wrote:
> > Maybe i was not enough clear. It seems to me that new behaviour, with
> > vlan on top of bridge rather than above interface in bridge is not
> > functional.
> > In other words, i cannot use vlan and bridge together in 2.6.38 (with 
> > e1000e).
> 
> Sorry, I misunderstood what you were saying before.  Can you try and
> see where the packets are getting lost or improperly handled by
> running tcpdump on the various interfaces?  For example, check that
> packets are coming in with tags on the physical interfaces, have tags
> on the bridge interface, no tag on the vlan interface, etc.

I think I ran into the same problem, and my workaround for this was to add
a vlan do the bridge and then add the vlan'ed bridge to another bridge, i.e.
(since I can't draw, commands will be better :P)

brctl addbr br0
brctl addif br0 eth0
ip link add link br0 name br0.42 type vlan id 42
ip link set br0.42 up

brctl addbr br_42
brctl addif br_42 br0.42

and then I could put VMs in br_42 which got network "as expected"
before, I used to have br_42 with eth0.42 in it, so it is just one more
step..
What bothers me is that I also want to put VMs in br0, and it does work,
but this bridge also sees all the tagged data - isn't there a way to just
"pick" the untagged network?
My other question is that I'm not certain if that's the expected way to
use the new behaviour, if not I wouldn't mind light shining from above :)

This is enough for me, though I can't say I like the change I can't argue
that having everything behave the same way is better, but I'm still
curious...

Regards,
Dominique Martinet | Asmadeus

