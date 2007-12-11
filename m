From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9545] New: Cannot bring up a bridge interface
 without a MAC address set
Date: Tue, 11 Dec 2007 14:52:43 -0800
Message-ID: <20071211145243.66e1f66a@freepuppy.rosehill>
References: <bug-9545-10286@http.bugzilla.kernel.org/>
	<20071211132614.5854b0f1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	berrange@redhat.com, Jeff Garzik <jeff@garzik.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33487 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759701AbXLKWzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 17:55:38 -0500
In-Reply-To: <20071211132614.5854b0f1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Dec 2007 13:26:14 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> (please respond via emailed reply-to-all, not via the bugzilla web
> interface).
> 
> On Tue, 11 Dec 2007 11:04:55 -0800 (PST)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=9545
> > 
> >            Summary: Cannot bring up a bridge interface without a MAC address
> >                     set
> >            Product: Networking
> >            Version: 2.5
> >      KernelVersion: 2.6.24-0.81.rc4.git7.fc9
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Fedora
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: acme@ghostprotocols.net
> >         ReportedBy: berrange@redhat.com
> > 
> > 
> > Most recent kernel where this bug did not occur: Any 2.6.23 or earlier
> > Distribution: Fedora 9 rawhide
> > Hardware Environment: Intel(R) Core(TM)2 Duo CPU     E6850, x86_64
> > Software Environment:  2.6.24-0.81.rc4.git7.fc9 #1 SMP  x86_64 GNU/Linux
> > Problem Description:
> > It is not possible to bring up a bridge interface unless one first assigns a
> > MAC address to it. This is a regression from earlier kernels where one could
> > always bring up a bridge device immediately after creating it. The bridge
> > should not require a MAC address because it is not going to be configured with
> > any IP addr - in my scenario I merely wish to use it to connect a number of
> > 'tap' devices associated with KVM guests.
> > 
> > Steps to reproduce:
> > # brctl addbr demobr
> > # ifconfig demobr up
> > SIOCSIFFLAGS: Invalid argument

The tap devices have to have addresses don't they. So bringing up an empty
bridge is meaningless. If you just add the device first then it will work.

Could be fixed to prevent errors from existing scripts but it is not a complete showstopper.
The problem is that when device is brought up it propogates events up to
other layers and applications, these layers will then query and see a bogus
address.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
