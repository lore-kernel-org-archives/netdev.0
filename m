From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Thu, 18 Nov 2004 15:56:43 -0800
Message-ID: <OFC99BB8DD.C1F76875-ON88256F50.0082ECFE-88256F50.00838992@us.ibm.com>
References: <20041118234911.GA66056@calma.pair.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20041118234911.GA66056@calma.pair.com>
To: "Chad N. Tindel" <chad@tindel.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hmm, well, for fixed-length records, at least you could make the buffer

(pagesize/recordsize) * recordsize and avoid getting partial records,
though you could still miss some or get duplicates. At least they would
be complete records rather than a mix of unrelated ones.

Might be more intuitive semantics if the first read resulted in a complete
copy of the data at that point, fed back to the application in whatever
chunks it wants, but only if the buffering didn't eat lots of memory.

                                        +-DLS
