From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the m68k tree
Date: Mon, 17 May 2010 12:14:38 +1000
Message-ID: <20100517121438.63772f56.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
scripts/mod/file2alias.c between commit
52498c252690651f915aecbcd10e26bcbafbe2a3 ("m68k: amiga - Zorro bus
modalias support") from the m68k tree and commit
8626d3b4328061f5b82b11ae1d6918a0c3602f42 ("phylib: Support phy module
autoloading") from the net tree.

Again, just overlapping additions.  I fixed it up (see below) and can
carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc scripts/mod/file2alias.c
index df90f31,36a60a8..0000000
--- a/scripts/mod/file2alias.c
+++ b/scripts/mod/file2alias.c
@@@ -796,16 -796,28 +796,38 @@@ static int do_platform_entry(const cha
  	return 1;
  }
  
 +/* Looks like: zorro:iN. */
 +static int do_zorro_entry(const char *filename, struct zorro_device_id *id,
 +			  char *alias)
 +{
 +	id->id = TO_NATIVE(id->id);
 +	strcpy(alias, "zorro:");
 +	ADD(alias, "i", id->id != ZORRO_WILDCARD, id->id);
 +	return 1;
 +}
 +
+ static int do_mdio_entry(const char *filename,
+ 			 struct mdio_device_id *id, char *alias)
+ {
+ 	int i;
+ 
+ 	alias += sprintf(alias, MDIO_MODULE_PREFIX);
+ 
+ 	for (i = 0; i < 32; i++) {
+ 		if (!((id->phy_id_mask >> (31-i)) & 1))
+ 			*(alias++) = '?';
+ 		else if ((id->phy_id >> (31-i)) & 1)
+ 			*(alias++) = '1';
+ 		else
+ 			*(alias++) = '0';
+ 	}
+ 
+ 	/* Terminate the string */
+ 	*alias = 0;
+ 
+ 	return 1;
+ }
+ 
  /* Ignore any prefix, eg. some architectures prepend _ */
  static inline int sym_is(const char *symbol, const char *name)
  {
@@@ -953,10 -965,10 +975,14 @@@ void handle_moddevtable(struct module *
  		do_table(symval, sym->st_size,
  			 sizeof(struct platform_device_id), "platform",
  			 do_platform_entry, mod);
 +	else if (sym_is(symname, "__mod_zorro_device_table"))
 +		do_table(symval, sym->st_size,
 +			 sizeof(struct zorro_device_id), "zorro",
 +			 do_zorro_entry, mod);
+ 	else if (sym_is(symname, "__mod_mdio_device_table"))
+ 		do_table(symval, sym->st_size,
+ 			 sizeof(struct mdio_device_id), "mdio",
+ 			 do_mdio_entry, mod);
  	free(zeros);
  }
  
