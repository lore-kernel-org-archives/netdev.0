From: "Javier Cardona" <javier@cozybit.com>
Subject: Proposed interface for per-packet mesh-ttl
Date: Tue, 3 Jul 2007 12:29:24 -0700
Message-ID: <445f43ac0707031229m4ed60e0cg7960437c3e373c8e@mail.gmail.com>
References: <445f43ac0707031149o2b50fc0en48aef4130b4b60ec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.235]:25189 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757323AbXGCT3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 15:29:25 -0400
Received: by nz-out-0506.google.com with SMTP id s18so1328219nze
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2007 12:29:25 -0700 (PDT)
In-Reply-To: <445f43ac0707031149o2b50fc0en48aef4130b4b60ec@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Woodhouse suggested that this list is a more appropriate forum
for my message...

---------- Forwarded message ----------
From: Javier Cardona <javier@cozybit.com>
Date: Jul 3, 2007 11:49 AM
Subject: Proposed interface for per-packet mesh-ttl
To: libertas-dev@lists.infradead.org


Libertas-dev,

I'm currently working on per-packet mesh ttl.  My plan is to register
new mesh sockopts through netfilter.  The user interface will be:

#include <sys/types.h>
#include <sys/socket.h>

/* in mesh.h ? */
#define MESH_SO_SET_TTL         77
#define MESH_SO_GET_TTL         77

int main()
{
    int sock;
    int optlen;
    unsigned char ttl;

    ttl = 7;
    optlen = sizeof(ttl);

    sock = socket (PF_INET, SOCK_STREAM, 0);
    setsockopt(sock, SOL_IP, MESH_SO_SET_TTL, &ttl, optlen);
    getsockopt(sock, SOL_IP, MESH_SO_GET_TTL, &ttl, &optlen);

    /* from here on, all traffic from sock will be sent to the mesh
with ttl=7 */

    return 0;
}


Pros:

* it is non-intrusive (only need to reserve the socket option values,
no other changes to the net stack are needed)
* runtime configurable (this options may be supported only when a
mesh_opts module is loaded).
* familiar and intuitive (at least to me :)

Cons:

* netfilter only has hooks for IPv4 and IPv6.  If we want to make mesh
parameters configurable at other layers (e.g. packet) we'll have to
create the hooks.
* It is debatable whether a mesh option should be set at SOL_IP, as it
is a layer 2 protocol.    We do want (some) mesh options to be applied
to flows a that level, and the {g,s}etsockopt interface does not
support setting lower layer options to higher layer sockets.

Speak up if you would like to see this done in a different way.

Cheers,

Javier
