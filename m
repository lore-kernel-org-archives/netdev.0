From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK] XFRM Clean-Up xfrm_lookup()
Date: Sun, 21 Mar 2004 23:05:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040321230513.61e6e9eb.davem@redhat.com>
References: <20040320.135151.114415274.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040320.135151.114415274.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 20 Mar 2004 13:51:51 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Please pull the following changesets from <http://bk.skbuff.net:10772>.

Pulled, thanks Yoshfuji.

> (Sorry I don't know how to send changesets in e-mail.)

I attach a perl script that I use.  It works for me.
It would be really nice to see the actual diffs here and
not just change comments :)

Just do this:

bash$ bk changes -L -f >changes.out
bash$ ./csets-to-marcelo.pl <changes.out >foo.txt

Maybe you like the output, maybe you don't :)  You can edit it
to your tastes.

#!/usr/bin/perl -w

use strict;

my ($lhs, $rev, $tmp, $rhs, $s);
my @cset_text = ();
my @pipe_text = ();
my $have_cset = 0;

while (<>) {
	next if /^---/;

	if (($lhs, $tmp, $rhs) = (/^(ChangeSet\@)([^,]+)(, .*)$/)) {
		&cset_rev if ($have_cset);

		$rev = $tmp;
		$have_cset = 1;

		push(@cset_text, $_);
	}

	elsif ($have_cset) {
		push(@cset_text, $_);
	}
}
&cset_rev if ($have_cset);
exit(0);


sub cset_rev {
	my $empty_cset = 0;

	open PIPE, "bk export -tpatch -hdu -r $rev 2>/dev/null |" or die;
	while ($s = <PIPE>) {
		push(@pipe_text, $s);
	}
	close(PIPE);

	if (! $empty_cset) {
		print @cset_text;
		print @pipe_text;
		print "\n\n";
	}

	@pipe_text = ();
	@cset_text = ();
}
