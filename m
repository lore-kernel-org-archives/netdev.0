From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] am2150: Update nmclan_cs.c to use update PCMCIA API
Date: Thu, 18 Sep 2014 02:33:41 -0700
Message-ID: <1411032821-9753-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Roger Pao <rpao@paonet.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:27974 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755505AbaIRJdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 05:33:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resolves compile warning about use of a deprecated function call:
drivers/net/ethernet/amd/nmclan_cs.c: In function =E2=80=98nmclan_confi=
g=E2=80=99:
drivers/net/ethernet/amd/nmclan_cs.c:624:3: warning: =E2=80=98pcmcia_re=
quest_exclusive_irq=E2=80=99 is deprecated (declared at include/pcmcia/=
ds.h:213) [-Wdeprecated-declarations]
   ret =3D pcmcia_request_exclusive_irq(link, mace_interrupt);

Updates pcmcia_request_exclusive_irq() to pcmcia_request_irq().

CC: Roger Pao <rpao@paonet.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/amd/nmclan_cs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/nmclan_cs.c b/drivers/net/etherne=
t/amd/nmclan_cs.c
index abf3b15..5b22764 100644
--- a/drivers/net/ethernet/amd/nmclan_cs.c
+++ b/drivers/net/ethernet/amd/nmclan_cs.c
@@ -621,7 +621,7 @@ static int nmclan_config(struct pcmcia_device *link=
)
   ret =3D pcmcia_request_io(link);
   if (ret)
 	  goto failed;
-  ret =3D pcmcia_request_exclusive_irq(link, mace_interrupt);
+  ret =3D pcmcia_request_irq(link, mace_interrupt);
   if (ret)
 	  goto failed;
   ret =3D pcmcia_enable_device(link);
--=20
1.9.3
