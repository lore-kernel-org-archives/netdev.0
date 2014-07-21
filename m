From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: solos-pci.c: Fix me
Date: Mon, 21 Jul 2014 09:14:45 -0400
Message-ID: <20140721091445.1ee700bb@thirdoffive.cmf.nrl.navy.mil>
References: <CAPDOMVjnK=OF8mQrXbbgGUtCRJO8oG4+PQOETEcskNk=95GLrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nick Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPDOMVjnK=OF8mQrXbbgGUtCRJO8oG4+PQOETEcskNk=95GLrg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 20 Jul 2014 00:59:42 -0400
Nick Krause <xerofoify@gmail.com> wrote:

> Hey Chas,
> There seems to be a fix me in this file in the function, solos_bh.
> Is the default statement correct and I remove the fix me or
> does it need to be rewritten.
> Cheers Nick
> 

I am afraid that I don't know enough about the solos hardware to know
if it needs to be rewritten.  I gather the solos returns at least three
kinds of packets, data, status and command.  If you wish to eliminate
the FIXME comment, you could just write:

@@ -850,8 +850,7 @@ static void solos_bh(unsigned long card_arg)
                                dev_kfree_skb_any(skb);
                                break;
 
-                       case PKT_COMMAND:
-                       default: /* FIXME: Not really, surely? */
+                       default: /* PKT_COMMAND */
                                if (process_command(card, port, skb))
                                        break;
                                spin_lock(&card->cli_queue_lock);

and be done with it since that will preserve existing behavior.
