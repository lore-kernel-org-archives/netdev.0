From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/1 net-next] Bluetooth: fix shadow warning in hci_disconnect()
Date: Thu, 23 Oct 2014 09:29:08 -0700
Message-ID: <2F67F6E8-CA99-4998-AE68-89E60D62C39D@holtmann.org>
References: <1414081365-6461-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Fabian Frederick <fabf@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:57092 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbaJWQ3Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 12:29:16 -0400
In-Reply-To: <1414081365-6461-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fabian,

> use cpr for hci_cp_read_clock_offset instead of cp
> (already defined above).
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
> net/bluetooth/hci_conn.c | 6 +++---
> 1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
> index b9517bd..6151e09 100644
> --- a/net/bluetooth/hci_conn.c
> +++ b/net/bluetooth/hci_conn.c
> @@ -141,10 +141,10 @@ int hci_disconnect(struct hci_conn *conn, __u8 reason)
> 	 */
> 	if (conn->type == ACL_LINK && conn->role == HCI_ROLE_MASTER) {
> 		struct hci_dev *hdev = conn->hdev;
> -		struct hci_cp_read_clock_offset cp;
> +		struct hci_cp_read_clock_offset cpr;
> 
> -		cp.handle = cpu_to_le16(conn->handle);
> -		hci_send_cmd(hdev, HCI_OP_READ_CLOCK_OFFSET, sizeof(cp), &cp);
> +		cpr.handle = cpu_to_le16(conn->handle);
> +		hci_send_cmd(hdev, HCI_OP_READ_CLOCK_OFFSET, sizeof(cpr), &cpr);

valid change, but I do not like cpr as variable name. We need to come up with a better one. There are other places in the code where we had the same thing. Please have a look there.

Regards

Marcel
