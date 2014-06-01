From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: bluetooth: hci_core.c:  Cleaning up uninitialized variables
Date: Sun, 1 Jun 2014 16:24:21 +0200
Message-ID: <AB19A214-D495-44EE-87E0-45332F156767@holtmann.org>
References: <1401631076-20818-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth <linux-bluetooth@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33919 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbaFAOY0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 10:24:26 -0400
In-Reply-To: <1401631076-20818-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rickard,

> There is a risk that the variable will be used without being initialized.
> 
> This was largely found by using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
> net/bluetooth/hci_core.c |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
> index 1c6ffaa..1d93d2f 100644
> --- a/net/bluetooth/hci_core.c
> +++ b/net/bluetooth/hci_core.c
> @@ -4603,7 +4603,7 @@ static struct hci_chan *hci_chan_sent(struct hci_dev *hdev, __u8 type,
> 	struct hci_chan *chan = NULL;
> 	unsigned int num = 0, min = ~0, cur_prio = 0;
> 	struct hci_conn *conn;
> -	int cnt, q, conn_num = 0;
> +	int cnt, q = 0, conn_num = 0;

I have no idea on how the variable will be used without being initialized. Have you actually looked through that function. The only thing we do with q is assign it and then use it. That is it.

Regards

Marcel
