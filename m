From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: pull request: batman-adv 2011-09-08
Date: Thu,  8 Sep 2011 18:40:44 +0200
Message-ID: <1315500051-1122-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

here comes the next batch batch I'd like to get the pulled into 
net-next-2.6/3.2. These patches mainly focus restructering the 
routing code in order to allow the kernel module the handling
of the current routing algorithm and the upcoming one. 

To ensure a smooth transition and efficient testing later, we 
decided to offer a choice of routing algorithm but have not     
come to a final decision on how to design this choice yet. It
either will be a compile time option, a module parameter or a
runtime switch. Any suggestions / best practice tips ?

Note: The new algorithm has been designed with backward 
compatibility in mind (using TLVs). We are trying to address
the incompatibility issue you and others have pointed out.

Thanks,
Marek

The following changes since commit a943cac144e035c21d4f1b31b95f15b33c33a480:

  batman-adv: merge update_transtable() into tt related code (2011-08-22 15:16:22 +0200)

are available in the git repository at:
  git://git.open-mesh.org/linux-merge.git batman-adv/next

Joe Perches (1):
      batman-adv: Remove unnecessary OOM logging messages

Marek Lindner (4):
      batman-adv: rename all instances of batman_packet to batman_ogm_packet
      batman-adv: agglomerate all batman iv ogm processing functions in a single file
      batman-adv: move routing packet initialization into corresponding file
      batman-adv: agglomerate all batman iv ogm sending functions in the batman iv file

Simon Wunderlich (1):
      batman-adv: update README (date & ap isolation sysfs file)

Sven Eckelmann (1):
      batman-adv: update internal version number

 Documentation/networking/batman-adv.txt     |    8 +-
 net/batman-adv/Makefile                     |    2 +-
 net/batman-adv/aggregation.c                |  293 -------
 net/batman-adv/bat_iv_ogm.c                 | 1170 +++++++++++++++++++++++++++
 net/batman-adv/{aggregation.h => bat_ogm.h} |   30 +-
 net/batman-adv/hard-interface.c             |   54 +-
 net/batman-adv/main.c                       |    2 -
 net/batman-adv/main.h                       |    2 +-
 net/batman-adv/originator.c                 |   19 +-
 net/batman-adv/packet.h                     |   18 +-
 net/batman-adv/routing.c                    |  602 +-------------
 net/batman-adv/routing.h                    |   17 +-
 net/batman-adv/send.c                       |  305 +-------
 net/batman-adv/send.h                       |    9 +-
 net/batman-adv/soft-interface.c             |   21 +-
 net/batman-adv/vis.c                        |    4 +-
 16 files changed, 1281 insertions(+), 1275 deletions(-)
 delete mode 100644 net/batman-adv/aggregation.c
 create mode 100644 net/batman-adv/bat_iv_ogm.c
 rename net/batman-adv/{aggregation.h => bat_ogm.h} (50%)
