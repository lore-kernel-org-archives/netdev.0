From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: Understanding the reason for placing a tcp_sock on stack in tcp network functions
Date: Tue, 1 Mar 2005 07:13:48 -0300
Message-ID: <39e6f6c70503010213214101a@mail.gmail.com>
References: <1109638277.9693.15.camel@base.torri.org>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
To: Stephen Torri <storri@torri.org>
In-Reply-To: <1109638277.9693.15.camel@base.torri.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is not the case for at least some of these functions:

ChangeSet@1.2035.2.55, 2005-02-22 10:48:28-08:00, acme@conectiva.com.br
  [TCP]: Fix excessive stack usage resulting in OOPS with 4KSTACKS.

  Various routines were putting a full struct tcp_sock on
  the local stack.  What they really wanted was a subset
  of this information when doing TCP options processing
  when we only have a mini-socket (for example in SYN-RECVD
  and TIME_WAIT states).

  Therefore pull out the needed information into a sub-struct
  and use that in the TCP options processing routines.

  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


On Mon, 28 Feb 2005 19:51:17 -0500, Stephen Torri <storri@torri.org> wrote:
> I am trying to help out reducing the stack size of functions in the
> kernel. The function names and values below, with comments and
> questions, was obtained of the linux-2.6 kernel kept at bkbits.net when
> I did 'make checkstack'.
