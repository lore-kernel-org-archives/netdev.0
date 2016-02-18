From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net v2] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Thu, 18 Feb 2016 10:42:04 +0100
Message-ID: <1455788524.29084.8.camel@redhat.com>
References: <244994c83cb73d98205f39aaefcee846dab48260.1455731463.git.pabeni@redhat.com>
	 <CAEh+42isC=4nmKz-Sjc9VreCbOkqdEcPc2uXyxcgGRJQsdSWSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Jiri Benc <jbenc@redhat.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <tom@herbertland.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42678 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425615AbcBRJmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:42:10 -0500
In-Reply-To: <CAEh+42isC=4nmKz-Sjc9VreCbOkqdEcPc2uXyxcgGRJQsdSWSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-02-17 at 11:19 -0800, Jesse Gross wrote:
> On Wed, Feb 17, 2016 at 10:30 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > the commit 35e2d1152b22 ("tunnels: Allow IPv6 UDP checksums to be
> > correctly controlled.") changed the default xmit checksum setting
> > for lwt vxlan/geneve ipv6 tunnels, so that now the checksum is not
> > set into external UDP header.
> > This commit changes the rx checksum setting for both lwt vxlan/geneve
> > devices created by openvswitch accordingly, so that lwt over ipv6
> > tunnel pairs are again able to communicate with default values.
> >
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> 
> This is compat code that is being changed here. Based on the previous
> discussion, shouldn't these be made the default for all users?

This change was initially aimed at a smaller scope: use self consistent
default for ovs lwt devices/tunnel terminations.

If there is agreement, I can post a separate patch changing the default
rx checksum setting for plain vxlan and geneve[1] devices tunneling over
ipv6.

Paolo

[1] according to the ietf draft the geneve devices have the same
checksum requirement than vxlan ones
