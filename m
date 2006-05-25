From: Paul Moore <paul.moore@hp.com>
Subject: [RFC 0/4] NetLabel
Date: Thu, 25 May 2006 16:06:01 -0400
Message-ID: <44760E29.4070407@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:16525 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1030384AbWEYUGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 16:06:05 -0400
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces a new kernel feature designed to support labeled
networking protocols such as RIPSO and CIPSO.  These protocols are required to
interoperate with existing "trusted" operating systems such as Trusted Solaris.
I am posting the patch now not because I feel it is ready for inclusion into
any of the main kernel trees but because it is usable and I would like to
solicit comments from the community sooner rather than later.

I know there has been at least one previous effort to get CIPSO support into
the kernel and that was rejected.  I have tried to take the feedback from that
patch into consideration with this patch and create a new mechanism which
treads as lightly as possible on the core networking stack.  I have also
worked to make the new patch LSM agnostic so that this code can be shared
amongst multiple LSMs; while I am only providing a patch for SELinux at this
point I do understand that there is at least one other LSM that is interested
in making use of this new mechanism.

I understand that there will probably need to be a lengthy review period due
to the size and complexity of this patch.  I also understand that my relative
inexperience with submitting patches to the Linux kernel will not do much to
help my cause but I appreciate your patience and any comments you may have.

There is a more information as well as a basic userspace tool for configuration
of the NetLabel subsystem here:

 * http://free.linux.hp.com/~pmoore/projects/linux_cipso

Thanks.

 CREDITS                                                   |    7
 Documentation/00-INDEX                                    |    2
 Documentation/netlabel/00-INDEX                           |   10
 Documentation/netlabel/cipso_ipv4.txt                     |   48
 Documentation/netlabel/draft-ietf-cipso-ipsecurity-01.txt |  791 +++++
 Documentation/netlabel/introduction.txt                   |   44
 Documentation/netlabel/lsm_interface.txt                  |   47
 include/linux/ip.h                                        |    1
 include/linux/netlink.h                                   |    1
 include/net/cipso_ipv4.h                                  |  179 +
 include/net/inet_sock.h                                   |    2
 include/net/netlabel.h                                    |  355 ++
 net/Kconfig                                               |    2
 net/Makefile                                              |    1
 net/ipv4/Makefile                                         |    1
 net/ipv4/cipso_ipv4.c                                     | 1568 ++++++++++
 net/ipv4/ip_fragment.c                                    |   38
 net/ipv4/ip_options.c                                     |   19
 net/netlabel/Kconfig                                      |   47
 net/netlabel/Makefile                                     |   15
 net/netlabel/netlabel_cipso_v4.c                          |  519 +++
 net/netlabel/netlabel_cipso_v4.h                          |  185 +
 net/netlabel/netlabel_domainhash.c                        |  629 ++++
 net/netlabel/netlabel_domainhash.h                        |   64
 net/netlabel/netlabel_kapi.c                              |  374 ++
 net/netlabel/netlabel_mgmt.c                              |  686 ++++
 net/netlabel/netlabel_mgmt.h                              |  265 +
 net/netlabel/netlabel_unlabeled.c                         |  289 +
 net/netlabel/netlabel_unlabeled.h                         |   90
 net/netlabel/netlabel_user.c                              |  166 +
 net/netlabel/netlabel_user.h                              |   42
 security/selinux/hooks.c                                  |   64
 security/selinux/include/security.h                       |    6
 security/selinux/ss/ebitmap.c                             |  155
 security/selinux/ss/ebitmap.h                             |    6
 security/selinux/ss/mls.c                                 |  160 +
 security/selinux/ss/mls.h                                 |   25
 security/selinux/ss/services.c                            |  252 +
 security/selinux/xfrm.c                                   |   22
 39 files changed, 7156 insertions(+), 21 deletions(-)

-- 
paul moore
linux security @ hp
