From: Eric Paris <eparis@parisplace.org>
Subject: Re: [RFC PATCH v1 2/2] selinux: Support for the new TUN LSM hooks
Date: Wed, 5 Aug 2009 09:06:56 -0400
Message-ID: <7e0fb38c0908050606o2aa1a718x599c101592ec1ce8@mail.gmail.com>
References: <20090804211304.10798.65601.stgit@flek.lan>
	 <20090804212204.10798.53727.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f172.google.com ([209.85.212.172]:43961 "EHLO
	mail-vw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933744AbZHENG4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 09:06:56 -0400
In-Reply-To: <20090804212204.10798.53727.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 4, 2009 at 5:22 PM, Paul Moore<paul.moore@hp.com> wrote:
> Add support for the new TUN LSM hooks: security_tun_dev_create(),
> security_tun_dev_post_create() and security_tun_dev_attach(). =A0This=
 includes
> the addition of a new object class, tun_socket, which represents the =
socks
> associated with TUN devices. =A0The _tun_dev_create() and _tun_dev_po=
st_create()
> hooks are fairly similar to the standard socket functions but _tun_de=
v_attach()
> is a bit special. =A0The _tun_dev_attach() is unique because it invol=
ves a
> domain attaching to an existing TUN device and its associated tun_soc=
ket
> object, an operation which does not exist with standard sockets and m=
ost
> closely resembles a relabel operation.
>
> This patch also includes a new policy capability, tun_perms, to ensur=
e that
> the new access controls do not affect older SELinux policies.

I think we finally have the first patch where the 'handle_unknown'
stuff fits better than the policy capabilities work!  First time for
everything!  I'd suggest dropping the policy capability all together
and the checks will be applied when the class and perm is defined in
the loaded policy.  If the class+perm isn't defined in policy the
policy handle_unknown setting will define the result of the security
check.

whoo hoo, saves 32bits of memory and 2 branches on low use operations!

-Eric
