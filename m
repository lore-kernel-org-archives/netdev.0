From: Shannon Nelson <shannon.nelson@intel.com>
Subject: Re: [Qemu-devel] PCI passthrough of 40G ethernet interface (Openstack/KVM)
Date: Thu, 19 Mar 2015 09:26:55 -0700
Message-ID: <CAP-MU4N8DsafjBWUVw5Fw0pdnjfYszbARpoRmnFn=s=MsQtGzw@mail.gmail.com>
References: <CA+AkT2g=vFxKAUrHzWDxPzfq_SNvOUJvzHe5YsX+p+p6Ad8hog@mail.gmail.com>
	<jpg8uf2ghln.fsf@redhat.com>
	<CA+AkT2hZ5e=YRkSqQnpQm9CgfC_fqs-m_05FTRZQLt9ynj9A4w@mail.gmail.com>
	<jpgtwxpvk5x.fsf@redhat.com>
	<CA+AkT2j9UUTVmEsW1B4D_cvfCTjp-+62qhvnYxcrthy=QmQcaw@mail.gmail.com>
	<CA+AkT2gXouCdMWzRJBY0jYi6O61OjDnNf7XGnfLzhYkJCe00mg@mail.gmail.com>
	<jpg1tko7qwb.fsf@redhat.com>
	<CA+AkT2i2z+DGV0aezUQaOLKrVupprniuxC19xGOuNnd6gC1ZGg@mail.gmail.com>
	<jpglhiw4tal.fsf@redhat.com>
	<jpgk2yewcpt.fsf@redhat.com>
	<CA+AkT2g-Xt+hcpoh2ETx70v0mzV6m=-5zpxJrhs2C8WF--kmWw@mail.gmail.com>
	<CAP-MU4PSMMOv-sjfDtKOSaHa9-dy3cMovsHV7V_cV1k6N7yvFg@mail.gmail.com>
	<CAP-MU4Pfv9W9FgaLxwOac3LnSJMxWcbYP4Pq43YjcJ9AWAamvQ@mail.gmail.com>
	<550A85B3.4070703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: jacob jacob <opstkusr@gmail.com>, Bandan Das <bsd@redhat.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	QEMU Developers <qemu-devel@nongnu.org>,
	kvm-devel <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:36149 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbbCSQ0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 12:26:55 -0400
In-Reply-To: <550A85B3.4070703@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2015 at 1:15 AM, Stefan Assmann <sassmann@redhat.com> wrote:
> Interesting, the following might explain why my XL710 feels a bit
> sketchy then. ;-)
> # ethtool -i p4p1
> driver: i40e
> version: 1.2.37-k
> firmware-version: f4.22.26225 a1.1 n4.24 e12ef
> Looks like the firmware on this NIC is even older.
>
> I tried to update the firmware with nvmupdate64e and the first thing I
> noticed is that you cannot update the firmware even with todays linux
> git. The tool errors out because it cannot access the NVM. Only with a
> recent net-next kernel I was able to update the firmware.
> ethtool -i p4p1
> driver: i40e
> version: 1.2.37-k
> firmware-version: f4.33.31377 a1.2 n4.42 e1932
>
> However during the update I got a lot of errors in dmesg.
> [  301.796664] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0702 received
> [  301.893933] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received
> [  302.005223] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received
> [...]
> [  387.884635] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received
> [  387.896862] i40e 0000:82:00.0: ARQ Overflow Error detected
> [  387.902995] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received

These are bogus messages should not have been generated, but it seems
there's a case statement missing in the upstream code.  I'll get a
patch together for this later today.

> [...]
> [  391.583799] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
> [  391.714217] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
> [  391.842656] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
> [  391.973080] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
> [  392.107586] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
> [  392.244140] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
> [  392.373966] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received

These are an annoying result of a user tool issue.

>
> Not sure if that flash was actually successful or not.

Since the driver was able to restart and give you the version
information from ethtool -i, the update was successful.  You are not
supposed to have to powercycle your system after the NVM update, but
it's a good idea anyway, especially when updating the older firmware
like what you had.

sln
