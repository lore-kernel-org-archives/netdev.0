From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] convering bonding driver /proc interface to seq_file
Date: Mon, 25 Aug 2003 08:45:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030825084521.4e3e916c.shemminger@osdl.org>
References: <E791C176A6139242A988ABA8B3D9B38A014C94C0@hasmsx403.iil.intel.com>
	<Mutt.LNX.4.44.0308250112470.21951-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Hen, Shmulik" <shmulik.hen@intel.com>,
   Chad Tindel <ctindel@users.sourceforge.net>,
   Jay Vosburgh <fubar@us.ibm.com>, "David S. Miller" <davem@redhat.com>,
   Jeff Garzik <jgarzik@pobox.com>, <bonding-devel@lists.sourceforge.net>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Mutt.LNX.4.44.0308250112470.21951-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 25 Aug 2003 01:15:13 +1000 (EST)
James Morris <jmorris@intercode.com.au> wrote:

> On Sat, 23 Aug 2003, Hen, Shmulik wrote:
> 
> > Also, instead of using a seq_file interface and using a
> > pointer to skip to the relevant part, we've used a different
> > proc creation interface that allows passing a pointer to bond
> > and thus retrieve just the relevant bond device's data.
> 
> Can you provide a pointer to this code?
> 
> seq_file is the standard and preferred way to do this kind of thing.

Using a pointer with seq_file was really easy.

init...
	bond->bond_proc_file = create_proc_entry(dev->name,
						 S_IRUGO, 
						 bond_proc_dir);
	if (bond->bonc_proc_file) {
		bond->bond_proc_file->data = bond;
		bond->bond_proc_file->proc_fops = &bond_info_fops;
	}

open...
	rc = seq_open(file, &bond_info_seq_ops);
	if (!rc) {
		seq = file->private_data;
		seq->private = PDE(inode)->data;
	}
