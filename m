From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: Re: [PATCH] Bluetooth: hci_core: Avoid mixing up req_complete and
 req_complete_skb
Date: Sat, 20 Feb 2016 09:04:30 +0200
Message-ID: <20160220070430.GA28199@t440s.ger.corp.intel.com>
References: <1455920722-20892-1-git-send-email-dianders@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>, gustavo@padovan.org,
	davem@davemloft.net, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Douglas Anderson <dianders@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455920722-20892-1-git-send-email-dianders@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Douglas,

On Fri, Feb 19, 2016, Douglas Anderson wrote:
> In commit 44d271377479 ("Bluetooth: Compress the size of struct
> hci_ctrl") we squashed down the size of the structure by using a union
> with the assumption that all users would use the flag to determine
> whether we had a req_complete or a req_complete_skb.
> 
> Unfortunately we had a case in hci_req_cmd_complete() where we weren't
> looking at the flag.  This can result in a situation where we might be
> storing a hci_req_complete_skb_t in a hci_req_complete_t variable, or
> vice versa.
> 
> During some testing I found at least one case where the function
> hci_req_sync_complete() was called improperly because the kernel thought
> that it didn't require an SKB.  Looking through the stack in kgdb I
> found that it was called by hci_event_packet() and that
> hci_event_packet() had both of its locals "req_complete" and
> "req_complete_skb" pointing to the same place: both to
> hci_req_sync_complete().
> 
> Let's make sure we always check the flag.
> 
> For more details on debugging done, see <http://crbug.com/588288>.
> 
> Fixes: 44d271377479 ("Bluetooth: Compress the size of struct hci_ctrl")
> Signed-off-by: Douglas Anderson <dianders@chromium.org>
> ---
> Testing was done on a Chrome OS device on kernel 3.14 w/
> bluetooth-next backports.  Since I couldn't reliably reproduce the
> problem, I simply confirmed that existing functionality worked.
> 
>  net/bluetooth/hci_core.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)

Good catch.

Acked-by: Johan Hedberg <johan.hedberg@intel.com>

Marcel, I think we want to send this through our stable tree to 4.5-rc
(where the patch introducing the bug is).

Johan
