From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] ixgbe: return error in set_rar when index out of
	range
Date: Tue, 18 May 2010 17:19:03 -0700
Message-ID: <AANLkTinu7M4fMmNXqlpMmMyRBySbY5lMGnRATI36xshZ@mail.gmail.com>
References: <1274196888.8701.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kvm@vger.kernel.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1274196888.8701.2.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 18, 2010 at 08:34, Shirley Ma <mashirle@us.ibm.com> wrote:
> Return -1 when set_rar index is out of range
>
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> ---
>
> =C2=A0drivers/net/ixgbe/ixgbe_common.c | =C2=A0 =C2=A01 +
> =C2=A01 files changed, 1 insertions(+), 0 deletions(-)
>


I think this should use IXGBE_ERR_<blah> instead and there is another
spot where this could be used.  Instead I propose this patch
instead...

ixgbe: return IXGBE_ERR_RAR_INDEX when out of range

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Based on patch from Shirley Ma <xma@us.ibm.com>
Return IXGBE_ERR_RAR_INDEX when RAR index is out of range, instead of
returning IXGBE_SUCCESS.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.c |    2 ++
 drivers/net/ixgbe/ixgbe_type.h   |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)


diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe=
_common.c
index 1159d91..9595b1b 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1188,6 +1188,7 @@ s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw,
u32 index, u8 *addr, u32 vmdq,
 		IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
 	} else {
 		hw_dbg(hw, "RAR index %d is out of range.\n", index);
+		return IXGBE_ERR_RAR_INDEX;
 	}

 	return 0;
@@ -1219,6 +1220,7 @@ s32 ixgbe_clear_rar_generic(struct ixgbe_hw *hw,
u32 index)
 		IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
 	} else {
 		hw_dbg(hw, "RAR index %d is out of range.\n", index);
+		return IXGBE_ERR_RAR_INDEX;
 	}

 	/* clear VMDq pool/queue selection for this RAR */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_t=
ype.h
index bd69196..37d2807 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2600,6 +2600,7 @@ struct ixgbe_info {
 #define IXGBE_ERR_FDIR_REINIT_FAILED            -23
 #define IXGBE_ERR_EEPROM_VERSION                -24
 #define IXGBE_ERR_NO_SPACE                      -25
+#define IXGBE_ERR_RAR_INDEX                     -26
 #define IXGBE_NOT_IMPLEMENTED                   0x7FFFFFFF

 #endif /* _IXGBE_TYPE_H_ */
