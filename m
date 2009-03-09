From: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Subject: Re: MACVLANs really best solution? How about a bridge with multiple
 bridge virtual interfaces? (was Re: [PATCH] macvlan: Support creating
 macvlans from macvlans)
Date: Mon, 9 Mar 2009 11:44:50 +1030
Message-ID: <20090309114450.f772b078.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
References: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
	<49B2A139.8040507@candelatech.com>
	<m11vt9fbgj.fsf@fess.ebiederm.org>
	<20090308090212.651e598b.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
	<49B3F82A.10103@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.mail.adnap.net.au ([203.6.132.75]:53988 "EHLO
	smtp1.mail.adnap.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406AbZCIBPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2009 21:15:07 -0400
In-Reply-To: <49B3F82A.10103@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Sun, 08 Mar 2009 09:54:02 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Mark Smith wrote:
> > On Sat, 07 Mar 2009 10:13:16 -0800
> > ebiederm@xmission.com (Eric W. Biederman) wrote:
> >
> >   
> >> Ben Greear <greearb@candelatech.com> writes:
> >>
> >>     
> >>> Mark Smith wrote:
> >>>       
> >>>> Hi,
> >>>>
> >>>> Ben said,
> >>>>   
> >>>>         
> >>>>> I wouldn't deny sending with wrong source mac..ethernet interfaces can do
> >>>>> this,
> >>>>> and mac-vlan should look as much like ethernet is possible.
> >>>>>     
> >>>>>           
> >>>> I agree, however there's further things that mac-vlans aren't
> >>>> currently doing as virtual ethernet interfaces that real ones do.
> >>>> Unicast ethernet traffic sent out one mac-vlan interface with a
> >>>> destination address of another mac-vlan interface on the same host
> >>>> isn't delivered. mac-vlan interfaces, even though they're conceptually
> >>>> located on the same ethernet segment, are currently isolated from each
> >>>> other for unicast traffic.
> >>>>   

<snip for brevity>

> > So then, my question is, what are mac-vlans for i.e. what is their
> > common use case?
> >
> > The problem I was trying to solve was to run up an arbitrary
> > number of PPPoE servers on a single LAN segment. I could do that
> > with physical interfaces, however I only had a maximum of 4 ethernet
> > interfaces in the host. Using mac-vlans seemed to be the obvious way to
> > eliminate the physical constraints of the host. I did expect though that
> > the mac-vlan virtual interfaces would work the same real interfaces, so
> > I was expecting that I could bridge them and that unicast traffic
> > between them would work.
> >   
> Doesn't pppoe always talk to an upstream box (the pppoe-server)?  If 
> that is so,
> why would the local mac-vlans ever need to communicate directly to 
> eachother?
> 

That's true, and in that sense, I was 'lucky' that I didn't encounter
this limitation in my test environment, but it was only because of my
test environment (i.e. protocol), didn't require unicast communication
between the mac-vlan interfaces on the same host. If I'd been testing
some other protocol that did require unicast communications between
macvlan interfaces, I would have been scratching my head, wondering
why things weren't working correctly, and may have spent a lot of time
thinking that my test setup was the thing that had failed, rather than
being caused by missing functionality that I assumed was there.

I think the "truth in advertising" or "principle of least surprise"
should hold - if mac-vlans are to be seen by their users as virtual
ethernet network cards, then they should function no differently to real
network cards, or alternatively, if they aren't going to function that
way, there needs to be quite obvious documentation somewhere (other
than this thread) about their limitations, and a corresponding
recommendation that you use bridged veth interfaces if you can't afford
those limitations. 

> We've used pppoe on mac-vlans, and it *seemed* to work, but perhaps we 
> were missing
> something...
> 
> I think they might also be useful for adding a more realistic 'virtual 
> ip' to an interface, perhaps
> for interesting routing setups.
> 
> Thanks,
> Ben
> 
> -- 
> Ben Greear <greearb@candelatech.com> 
> Candela Technologies Inc  http://www.candelatech.com
> 
> 
