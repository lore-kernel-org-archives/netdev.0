From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] locking changes for lec.c
Date: Fri, 14 Jan 2005 13:56:12 -0800
Message-ID: <20050114135612.0edc180d.davem@davemloft.net>
References: <200501061717.j06HHJ5I000508@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
In-Reply-To: <200501061717.j06HHJ5I000508@ginger.cmf.nrl.navy.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 06 Jan 2005 12:17:20 -0500
"chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil> wrote:

> after looking at things recently its not clear to me that the combination
> of lec_arp_lock and lec_arp_users was protecting things properly.
> here is a small rewrite that eliminates lec_arp_users completely and
> uses lec_arp_lock to protect the lists in lec_prev: lec_arp_tables,
> lec_arp_empty_ones, et al.

Can HW interrupt paths ever call into this ARP stuff?
If not, probably should just use BH disabled locking
instead of the heavy handed IRQ disabling locks.
