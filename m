From: Caitlin Bestler <caitlin.bestler@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
	objects
Date: Thu, 20 Aug 2009 13:58:20 -0700
Message-ID: <469958e00908201358q6128aefay4251873dbb44097c@mail.gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net>
	 <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com>
	 <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com>
	 <4A8AD678.7050609@redhat.com> <4A8B9B79.9050004@gmail.com>
	 <4A8BA5AE.3030308@redhat.com> <4A8C43D3.7030002@gmail.com>
	 <4A8C627C.70001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Patrick Mullaney <pmullaney@novell.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f175.google.com ([209.85.210.175]:35081 "EHLO
	mail-yx0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796AbZHTU6T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 16:58:19 -0400
In-Reply-To: <4A8C627C.70001@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2009 at 1:37 PM, Avi Kivity<avi@redhat.com> wrote:

>
> Well I'm not an Infiniband expert. =C2=A0But from what I understand V=
MM bypass
> means avoiding the call to the VMM entirely by exposing hardware regi=
sters
> directly to the guest.
>

It enables clients to talk directly to the hardware. Whether or not
that involves
registers would be model specific. But frequently the queues being writ=
ten
were in the client's memory, and only a "doorbell ring" involved actual=
 device
resources.

But whatever the mechanism, it enables the client to provide buffer add=
resses
directly to the hardware in a manner that cannot damage another client.=
 The two
key requirements are a) client cannot enable access to pages that it do=
es
not already have access to, and b) client can delegate that authority t=
o the
Adapter without needing to invoke OS or Hypervisor on a per message
basis.


Traditionally that meant that memory maps ("Regions") were created on t=
he
privileged path to enable fast/non-privileged references by the client.
