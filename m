From: Tom Lendacky <toml@us.ibm.com>
Subject: IPSec: 2.5.68 test results
Date: 24 Apr 2003 16:29:51 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1051219792.5206.52.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, toml@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


We've been running the TAHI IPSec test suites against the 2.5 kernel and
a TAHI based IKE test suite that I created.  I just wanted to post the
results so far (up through 2.5.68) for anyone who may be interested.

  Test			Successful	Attempted
  ipsec4-udp (IPv4)	48 (*)		48
  ipsec4 (IPv4)		95 (*)		95
  ipsec (IPv6)		114 (*)		118
  ike4 (IPv4)		111 (**)	111
  ike (IPv6)		111 (**)	111

  (*) Two warnings were issued during these tests.  The warnings related
      receiving and processing ESP data with padding that was not
      sequentially numbered (ie. three pad bytes of 000000 vs. 010203).
      However, RFC 2406 states only that the receiver SHOULD, not MUST,
      inspect the padding so there isn't anything to worry about here.

  (**) These results are based on a racoon patch that I have submitted
       to KAME to resolve three minor RFC related issues:
          - Do not accept or generate transforms that specify ESP NULL
            encryption without ESP authentication
          - Do not accept or generate multiple proposal payloads during
            phase 1 processing
          - Do not accept multiple transform payloads in response to
            the SA negotiation during phase 1 processing.

The four test cases that fail for the ipsec test are related to
fragment header processing and will need to be debugged and fixed.

Overall, these are very excellent results.

Thanks,
Tom
