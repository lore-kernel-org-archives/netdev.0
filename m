From: Samir Bellabes <sam@synack.fr>
Subject: [RFC 0/9] snet: Security for NETwork syscalls
Date: Sat,  2 Jan 2010 14:04:07 +0100
Message-ID: <1262437456-24476-1-git-send-email-sam@synack.fr>
Cc: Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello lsm and netdev people,
I would like to submit as a RFC this linux security module.

snet provides a mecanism to defer syscall security hooks and decision (verdict)
to userspace.

I believe that snet will help to get over the classical configuration
complexity of others security modules, by providing interactivity to users.
I also think that monolithic strategy is broken with snet, as we can provide
security for others syscall's categories:
 - sfs  : security for filesystem,
 - stask: security for task,
 - smem : security for memory,

In this way, and by putting abstraction on how this subsystems can talk to each
others, we may use the security combinaison we want: choose to run sfs,
stask, but not snet nor smem. Better, developpers may investigated how to build
another security subsystem for tasks, and use others existing (smem, snet..)
which they don't want to modify

I think that interactivity is very usefull for users, as they may be notify when
something is wrong and take decision, and from userspace, the decision may be
defered to another box. In this way, snet also have a advantage for mobile
devices as the policy decision will be push to a distant server, mobile device
will then wait for verdicts and as policy strategies are centralized.

snet has some subsystems :
 - core to init and exit the system
 - kernel/user communications (genetlink)
 - hashtable for events and verdict, and managing functions.
 - LSM hooks, classical security operations

Finally, and a important point: snet integration respects the LSM framework idea
of using LSM hooks

roadmap:
 * Building a cache for each task_struct using pointer (void*) security
   use the pointer (void*) security related to task_security to provides a
   verdict cache: if two identical requests are coming, ask the user for the
   first one, store the result in the cached and for the second request, just
   look in the cache
 * send data buffer of recvmsg and sendmsg to userspace
   this may provide a way to look inside the data (as a anti-virus do)
 * adding other security systems
   we can think about adding fork(), exec(), open(), close()..
   
I'm Ccing netfilter-devel, as snet may be see as a way to do filtering.

Samir Bellabes (9):
  lsm: add security_socket_closed()
  Revert "lsm: Remove the socket_post_accept() hook"
  snet: introduce security/snet, Makefile and Kconfig changes
  snet: introduce snet_core.c and snet.h
  snet: introduce snet_event.c and snet_event.h
  snet: introduce snet_hooks.c and snet_hook.h
  snet: introduce snet_netlink.c and snet_netlink.h
  snet: introduce snet_verdict.c and snet_verdict.h
  snet: introduce snet_utils.c and snet_utils.h

 include/linux/security.h             |   23 ++
 net/socket.c                         |    3 +
 security/Kconfig                     |    1 +
 security/Makefile                    |    2 +
 security/capability.c                |   10 +
 security/security.c                  |   10 +
 security/snet/Kconfig                |   22 ++
 security/snet/Makefile               |   13 +
 security/snet/include/snet.h         |   29 ++
 security/snet/include/snet_event.h   |   20 +
 security/snet/include/snet_hooks.h   |   28 ++
 security/snet/include/snet_netlink.h |  201 ++++++++++
 security/snet/include/snet_utils.h   |    9 +
 security/snet/include/snet_verdict.h |   33 ++
 security/snet/snet_core.c            |   77 ++++
 security/snet/snet_event.c           |  229 +++++++++++
 security/snet/snet_hooks.c           |  686 ++++++++++++++++++++++++++++++++++
 security/snet/snet_netlink.c         |  541 +++++++++++++++++++++++++++
 security/snet/snet_utils.c           |   40 ++
 security/snet/snet_verdict.c         |  210 +++++++++++
 20 files changed, 2187 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/Kconfig
 create mode 100644 security/snet/Makefile
 create mode 100644 security/snet/include/snet.h
 create mode 100644 security/snet/include/snet_event.h
 create mode 100644 security/snet/include/snet_hooks.h
 create mode 100644 security/snet/include/snet_netlink.h
 create mode 100644 security/snet/include/snet_utils.h
 create mode 100644 security/snet/include/snet_verdict.h
 create mode 100644 security/snet/snet_core.c
 create mode 100644 security/snet/snet_event.c
 create mode 100644 security/snet/snet_hooks.c
 create mode 100644 security/snet/snet_netlink.c
 create mode 100644 security/snet/snet_utils.c
 create mode 100644 security/snet/snet_verdict.c

