From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/12] make rpc_pipefs be mountable multiple times
Date: Tue, 21 Dec 2010 18:45:21 -0500
Message-ID: <20101221234520.GA30525@fieldses.org>
References: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
 <20101220144644.GC20643@fieldses.org>
 <20101221233215.GC7092@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Neil Brown <neilb@suse.de>,
	Pavel Emelyanov <xemul@parallels.com>,
	linux-nfs@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Kirill A. Shutemov" <kas@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101221233215.GC7092@shutemov.name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 22, 2010 at 01:32:15AM +0200, Kirill A. Shutemov wrote:
> On Mon, Dec 20, 2010 at 09:46:44AM -0500, J. Bruce Fields wrote:
> > By the way, was there ever a resolution to Trond's question?:
> > 
> > 	http://marc.info/?l=linux-nfs&m=128655758712817&w=2
> > 
> > 	"The keyring upcalls are currently initiated through the same
> > 	mechanism as module_request and therefore get started with the
> > 	init_nsproxy namespace. We'd really like them to run inside the
> > 	same container as the process.  As part of the same problem,
> > 	there is the issue of what to do with the dns resolver and
> > 	Bryan's new keyring based idmapper code."
> 
> I'm not sure that I understand the problem correctly.
> 
> Currently, idmap uses dentry taken from client's cl_rpcclient->cl_path
> (see nfs_idmap_new()). cl_rpcclient (and cl_path) is initialized with
> rpcmount resolved against mount namespace of mount process (see
> nfs_create_rpc_client()).
> I assume it's correct.

There's actually two separate sets of idmapper code; look at
fs/nfs/idmapper.c, the first part of the file (between #ifdef
CONFIG_NFS_USE_NEW_IDMAPPER and #else) is idmapping code that uses
request_key().  The code you're looking at (including nfs_idmap_new())
is later in the file, and deprecated.

--b.
