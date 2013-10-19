From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 0/6] ipv4: tcp_memcontrol and userns sysctls
Date: Sat, 19 Oct 2013 16:23:19 -0700
Message-ID: <87r4bghml4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org


While looking into allowing the ipv4 sysctls to be used in a network
namespace I stumbled upon the mess that is tcp_memcontrol.

I remove the dead code, broken code, and excessive abstraction in the
tcp_memcontrols then I clean up up and allow in the user namespace the
per net ipv4 sysctls.

Eric W. Biederman (6):
      tcp_memcontrol: Remove tcp_max_memory
      tcp_memcontrol: Remove setting cgroup settings via sysctl
      tcp_memcontrol: Remove the per netns control.
      tcp_memcontrol: Kill struct tcp_memcontrol
      ipv4: Use math to point per net sysctls into the appropriate struct net.
      ipv4: Allow unprivileged users to use per net sysctls

 include/net/netns/ipv4.h     |    1 -
 include/net/sock.h           |   28 ++++++------
 include/net/tcp.h            |    3 +-
 include/net/tcp_memcontrol.h |   12 ------
 mm/memcontrol.c              |    6 +-
 net/ipv4/af_inet.c           |    2 -
 net/ipv4/sysctl_net_ipv4.c   |   85 ++++++----------------------------------
 net/ipv4/tcp.c               |   12 +++--
 net/ipv4/tcp_ipv4.c          |    1 +
 net/ipv4/tcp_memcontrol.c    |   90 ++++++++---------------------------------
 net/ipv6/af_inet6.c          |    2 -
 net/ipv6/tcp_ipv6.c          |    1 +
 12 files changed, 57 insertions(+), 186 deletions(-)


Eric
