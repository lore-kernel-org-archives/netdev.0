From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: linux-next: manual merge of the random tree with the net-next
 tree
Date: Tue, 12 Nov 2013 09:55:29 +0100
Message-ID: <5281ED01.5020204@redhat.com>
References: <20131112155549.c160273993147244ed6bc81d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Theodore Ts'o" <tytso@mit.edu>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20131112155549.c160273993147244ed6bc81d@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On 11/12/2013 05:55 AM, Stephen Rothwell wrote:
> Hi Ted,
>
> Today's linux-next merge of the random tree got a conflict in
> drivers/char/random.c between commit 0244ad004a54 ("random32: add
> prandom_reseed_late() and call when nonblocking pool becomes
> initialized") from the net-next tree and commit 301f0595c0e7 ("random:
> printk notifications for urandom pool initialization") from the random
> tree.
>
> I fixed it up (probably not properly - see below) and can carry the fix
> as necessary (no action is required).

As per Hannes' suggestion, the result should look like (see cover
letter in [1]):

if (r->entropy_total > 128) {
	r->initialized = 1;
	r->entropy_total = 0;
	if (r == &nonblocking_pool) {
		prandom_reseed_late();
		pr_notice("random: %s pool is initialized\n",
			  r->name);
	}
}

Cheers,

Daniel

  [1] http://thread.gmane.org/gmane.linux.network/290303
