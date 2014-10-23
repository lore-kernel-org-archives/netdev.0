From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/1 net-next] Bluetooth: fix shadow warning in hci_disconnect()
Date: Thu, 23 Oct 2014 15:09:36 -0700
Message-ID: <AB7C94CC-9608-4BE7-B5C6-B89B64403D83@holtmann.org>
References: <1414081365-6461-1-git-send-email-fabf@skynet.be> <2F67F6E8-CA99-4998-AE68-89E60D62C39D@holtmann.org> <20326343.74480.1414085453988.open-xchange@webmail.nmp.skynet.be>
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20326343.74480.1414085453988.open-xchange@webmail.nmp.skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fabian,

>>> use cpr for hci_cp_read_clock_offset instead of cp
>>> (already defined above).
>>> 
>>> Signed-off-by: Fabian Frederick <fabf@skynet.be>
>>> ---
>>> net/bluetooth/hci_conn.c | 6 +++---
>>> 1 file changed, 3 insertions(+), 3 deletions(-)
>>> 
>>> diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
>>> index b9517bd..6151e09 100644
>>> --- a/net/bluetooth/hci_conn.c
>>> +++ b/net/bluetooth/hci_conn.c
>>> @@ -141,10 +141,10 @@ int hci_disconnect(struct hci_conn *conn, __u8 reason)
>>>       */
>>>      if (conn->type == ACL_LINK && conn->role == HCI_ROLE_MASTER) {
>>>              struct hci_dev *hdev = conn->hdev;
>>> -           struct hci_cp_read_clock_offset cp;
>>> +           struct hci_cp_read_clock_offset cpr;
>>> 
>>> -           cp.handle = cpu_to_le16(conn->handle);
>>> -           hci_send_cmd(hdev, HCI_OP_READ_CLOCK_OFFSET, sizeof(cp), &cp);
>>> +           cpr.handle = cpu_to_le16(conn->handle);
>>> +           hci_send_cmd(hdev, HCI_OP_READ_CLOCK_OFFSET, sizeof(cpr), &cpr);
>> 
>> valid change, but I do not like cpr as variable name. We need to come up with
>> a better one. There are other places in the code where we had the same thing.
>> Please have a look there.
> 
>   Maybe read_cp (like commit c1f23a2bfc89 with struct hci_cp_auth_requested
> auth_cp) ?

lets use clkoff_cp unless someone comes up with a better name.

Regards

Marcel
