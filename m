From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 4/5] net: dsa: mv88e6xxx: exclude all ports in new VLAN
Date: Wed,  7 Jun 2017 18:12:16 -0400
Message-ID: <20170607221217.2323-5-vivien.didelot@savoirfairelinux.com>
References: <20170607221217.2323-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607221217.2323-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the DSA core adds the CPU and DSA ports itself to the new VLAN
entry, there is no need to include them as members of this VLAN when
initializing a new VTU entry.

As of now, initialize a new VTU entry with all ports excluded.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 962b4e873bf9..41202b1d6d7f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1159,11 +1159,10 @@ static int mv88e6xxx_vtu_get(struct mv88e6xxx_chip *chip, u16 vid,
 		entry->valid = true;
 		entry->vid = vid;
 
-		/* Include only CPU and DSA ports */
+		/* Exclude all ports */
 		for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
-			entry->member[i] = dsa_is_normal_port(chip->ds, i) ?
-				GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER :
-				GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED;
+			entry->member[i] =
+				GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
 		return mv88e6xxx_atu_new(chip, &entry->fid);
 	}
-- 
2.13.1
