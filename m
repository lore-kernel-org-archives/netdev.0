From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] string matching based packet classification/filtering
Date: Wed, 16 Feb 2005 23:30:38 +0100
Message-ID: <20050216223038.GQ31837@postel.suug.ch>
References: <20050215203211.GL31837@postel.suug.ch>
	<42126C9B.5060406@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <42126C9B.5060406@eurodev.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

> Actually I wanted to contact Harald after this friday, once I'm done 
> with my exams. I'd like to merge my work with his libqsearch hackings 
> that were about to be finished.

Thinking about it, we can use the architecture to implement a regular
expression match. The pattern would consist of an array of tokens
in the form of:

struct regexp_token
{
	__u8 type;
	__u8 recur;
	__u8 value;
	__u8 unused;
};

where type would be
  - specific character (must match `value')
  - wildcard
  - digit
  - xdigit
  - alpha ...

and recur
 - 1
 - 0..1
 - 0..n
 - 1..0

The matching algorithm would parse the array as a finite automation
eating up byte by byte in the text. I think it would be efficient
enough, easy to implement, not too error prone and powerful enough
for most needs but we can discuss this in more details once libqsearch
is ready. It would be one step closer to the increasing need for 
application level based filtering and classification.
