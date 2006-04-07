From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch] ipv4: initialize arp_tbl rw lock
Date: Fri, 7 Apr 2006 07:46:27 -0700
Message-ID: <20060407074627.2f525b2e@localhost.localdomain>
References: <20060407081533.GC11353@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Frank Pavlic <fpavlic@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932446AbWDGOqq@vger.kernel.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
In-Reply-To: <20060407081533.GC11353@osiris.boeblingen.de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 7 Apr 2006 10:15:33 +0200
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> The qeth driver makes use of the arp_tbl rw lock. CONFIG_DEBUG_SPINLOCK
> detects that this lock is not initialized as it is supposed to be.
> 
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> ---

This is a initialization order problem then, because:
	arp_init
	   neigh_table_init
		rwlock_init

does the initialization already. So fix the initialization sequence
of the qeth driver or you will have other problems.

My impression was the -rt folks wanted all lock initializations t be
done at runtime not compile time.
