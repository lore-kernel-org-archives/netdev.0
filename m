From: James Morris <jmorris@redhat.com>
Subject: Developers please read: changes in Netfilter.
Date: Fri, 4 Jun 2004 19:55:57 -0400 (EDT)
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <Xine.LNX.4.44.0406041936330.14989-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

Netfilter developers should be aware of a changeset now merged into Linus'
bk tree.  A section of code in nf_hook_slow() which invalidates hardware
checksums and recalculates them on output paths has been removed and
pushed up to the Netfilter components which actually mangle packets (e.g.
NAT).

What this means is that any new code, or out of tree code (e.g. POM) needs
to be reviewed to ensure that it handles hardware checksumming correctly
itself, as the netfilter core code no longer does this.  (Although note 
that NAT targets/helpers are covered automatically).

Briefly, what needs to be done is: before mangling a packet in a way which
might affect the TCP or UDP checksum, if the packet has hardware
checksumming enabled, call skb_checksum_help().

For more details & code examples, refer to the changeset info:
<http://linux.bkbits.net:8080/linux-2.5/cset@40c002854YGOfqN8yOMFH8gC2xarLw?nav=index.html|ChangeSet@-1d>
<http://linux.bkbits.net:8080/linux-2.5/cset@40c0e261NUNg6uPWlw-lTjG5StoDwQ?nav=index.html|ChangeSet@-1d>



- James
-- 
James Morris
<jmorris@redhat.com>
