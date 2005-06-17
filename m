From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [ipv4, e1000] multi client throughput testing
Date: Thu, 16 Jun 2005 17:48:23 -0700
Message-ID: <42B21DD7.3@intel.com>
References: <Pine.WNT.4.63.0506101507450.2756@jbrandeb-desk.amr.corp.intel.com> <20050610.171127.59653238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org, jheffner@psc.edu,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050610.171127.59653238.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ick, I get to be the bearer of my own bad news.  I seem to mostly have a 
client misconfiguration problem.

David S. Miller wrote:
 > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
 > Date: Fri, 10 Jun 2005 16:56:50 -0700 (Pacific Daylight Time)
 >
 >  > What did i miss?
 >
 > Thanks for all of the data Jesse.  I'll try to sift through it this
 > weekend.

Well, as it turns out I was sort of right all along, when i was thinking 
that the client's tcp windows were not being serviced quickly enough.
First, I figured out that the windows client machines have a good "out 
of the box" behavior when receiving tcp data from linux.
Second, the clients sending data to the server were maxing out their tcp 
window at 64k and did *not* have rfc1323 enabled.  After enabling 
rfc1323 and upping the max window size to 128k, each client's throughput 
went up quite a bit (there may be more headroom i didn't test yet). 
Total throughput for us in this case is around 1560Mb/s now.  I'd like 
to see it at 1700-1800 but I don't think it will do it.  We're still 
running almost entirely in interrupt mode (with NAPI enabled) at about 
7-8000 ints/s

Now I will go back and run with the netfilter enabled kernel and take a 
look again at the faster replenish/fairness patches I've been working on.

Thanks for your attention,
  Jesse
