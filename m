From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] bluetooth.h: __ variants of u8 and friends are not
 neccessary inside kernel
Date: Wed, 5 Oct 2016 13:14:53 +0200
Message-ID: <368810F9-519C-44B5-85D4-1815273438BF@holtmann.org>
References: <20161003085640.GA8130@amd>
Mime-Version: 1.0 (Mac OS X Mail 10.0 \(3226\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: trivial@kernel.org, "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161003085640.GA8130@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel,

> bluetooth.h is not part of user API, so __ variants are not neccessary
> here.
> 
> Signed-off-by: Pavel Machek <pavel@ucw.cz>
> 
> diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
> index bfd1590..aea0371 100644
> --- a/include/net/bluetooth/bluetooth.h
> +++ b/include/net/bluetooth/bluetooth.h
> @@ -60,8 +60,8 @@
> 
> #define BT_SECURITY	4
> struct bt_security {
> -	__u8 level;
> -	__u8 key_size;
> +	u8 level;
> +	u8 key_size;
> };
> #define BT_SECURITY_SDP		0
> #define BT_SECURITY_LOW		1
> @@ -78,7 +78,7 @@ struct bt_security {
> 
> #define BT_POWER	9
> struct bt_power {
> -	__u8 force_active;
> +	u8 force_active;
> };
> #define BT_POWER_FORCE_ACTIVE_OFF 0
> #define BT_POWER_FORCE_ACTIVE_ON  1
> @@ -112,7 +112,7 @@ struct bt_power {
> 
> #define BT_VOICE		11
> struct bt_voice {
> -	__u16 setting;
> +	u16 setting;
> };
> 
> #define BT_VOICE_TRANSPARENT			0x0003
> @@ -188,7 +188,7 @@ static inline const char *state_to_string(int state)
> 
> /* BD Address */
> typedef struct {
> -	__u8 b[6];
> +	u8 b[6];
> } __packed bdaddr_t;
> 

can you leave these out please. They are meant to become UAPI eventually.

> /* BD Address type */
> @@ -196,7 +196,7 @@ typedef struct {
> #define BDADDR_LE_PUBLIC	0x01
> #define BDADDR_LE_RANDOM	0x02
> 
> -static inline bool bdaddr_type_is_valid(__u8 type)
> +static inline bool bdaddr_type_is_valid(u8 type)
> {
> 	switch (type) {
> 	case BDADDR_BREDR:
> @@ -208,7 +208,7 @@ static inline bool bdaddr_type_is_valid(__u8 type)
> 	return false;
> }
> 
> -static inline bool bdaddr_type_is_le(__u8 type)
> +static inline bool bdaddr_type_is_le(u8 type)
> {
> 	switch (type) {
> 	case BDADDR_LE_PUBLIC:
> @@ -278,15 +278,16 @@ struct sock *bt_accept_dequeue(struct sock *parent, struct socket *newsock);
> 
> /* Skb helpers */
> struct l2cap_ctrl {
> -	__u8	sframe:1,
> +	u8	sframe:1,
> 		poll:1,
> 		final:1,
> 		fcs:1,
> 		sar:2,
> 		super:2;
> -	__u16	reqseq;
> -	__u16	txseq;
> -	__u8	retries;
> +
> +	u16	reqseq;
> +	u16	txseq;
> +	u8	retries;
> 	__le16  psm;
> 	bdaddr_t bdaddr;
> 	struct l2cap_chan *chan;
> @@ -302,7 +303,7 @@ typedef void (*hci_req_complete_skb_t)(struct hci_dev *hdev, u8 status,
> #define HCI_REQ_SKB	BIT(1)
> 
> struct hci_ctrl {
> -	__u16 opcode;
> +	u16 opcode;
> 	u8 req_flags;
> 	u8 req_event;
> 	union {
> @@ -312,10 +313,10 @@ struct hci_ctrl {
> };
> 
> struct bt_skb_cb {
> -	__u8 pkt_type;
> -	__u8 force_active;
> -	__u16 expect;
> -	__u8 incoming:1;
> +	u8 pkt_type;
> +	u8 force_active;
> +	u16 expect;
> +	u8 incoming:1;
> 	union {
> 		struct l2cap_ctrl l2cap;
> 		struct hci_ctrl hci;
> @@ -365,7 +366,7 @@ out:
> 	return NULL;
> }
> 
> -int bt_to_errno(__u16 code);
> +int bt_to_errno(u16 code);

The rest looks good to me.

Regards

Marcel
