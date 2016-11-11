From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: AF_VSOCK loopback
Date: Fri, 11 Nov 2016 14:14:44 +0000
Message-ID: <BY2PR0501MB20561F98987156779668ECB1DABB0@BY2PR0501MB2056.namprd05.prod.outlook.com>
References: <20161110144329.GA19683@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "cavery@redhat.com" <cavery@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-001.vmware.com ([208.91.0.189]:55731 "EHLO
        EX13-EDG-OU-001.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750714AbcKKOQX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 09:16:23 -0500
In-Reply-To: <20161110144329.GA19683@stefanha-x1.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefan,

All datagram communication in VMCI based AF_VSOCK is going through the host=
 - also for loopback communication. The only difference wrt loopback is tha=
t the VMCI queue pairs implementing the shared queues for the stream protoc=
ols aren't registered with the hypervisor - they are created specifying the=
 VMCI_QPFLAG_LOCAL flag, and exist only as local guest memory.

So in the current form, there isn't much loopback code in the vmci AF_VSOCK=
 implementation, so it doesn't seem like there would be much to share eithe=
r.

Thanks,
J=F8rgen

________________________________________
From: Stefan Hajnoczi <stefanha@redhat.com>
Sent: Thursday, November 10, 2016 3:43 PM
To: Jorgen S. Hansen
Cc: cavery@redhat.com; netdev@vger.kernel.org
Subject: AF_VSOCK loopback

Hi Jorgen,
Cathy Avery found that the AF_VSOCK VMCI transport does loopback inside
the guest (but not on the host?).  The virtio transport currently does
no loopback.

The loopback scenario I'm thinking of is where process A listens on port
1234 and process B on the same machine connects to port 1234 both with
the same CID.

I'd like to make the virtio transport compatible with VMCI transport
semantics so AF_VSOCK behaves the same regardless of the transport.
This means loopback must be added to virtio-vsock.

The core net/vmware/af_vsock.c code does not implement loopback.  How
does VMCI do loopback?  Are the loopback packets reflected back from the
host?  Or does the guest driver notice the loopback and avoid passing
packets to the host in the first place?

Maybe we can make the loopback code common in af_vsock.c if that avoids
code duplication.

Thanks,
Stefan
