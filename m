From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] bug in ARP override timer near jiffies wrap
Date: Fri, 7 May 2004 14:40:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040507144000.7a57d76a.davem@redhat.com>
References: <OF2E0715FD.603FFEE2-ON88256E8D.006DBE22-88256E8D.006DF160@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF2E0715FD.603FFEE2-ON88256E8D.006DBE22-88256E8D.006DF160@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 7 May 2004 14:01:10 -0600
David Stevens <dlstevens@us.ibm.com> wrote:

> This patch fixes the calculation of "override" in ARP.
 ...
> -               if (jiffies - n->updated >= n->parms->locktime)
> -                       override = 1;
> +               override = time_after(jiffies, n->updated + 
> n->parms->locktime);

David, do you realize that the existing formula is not only
correct, but also covers a greater time space than the
time_*() mechanisms do?
