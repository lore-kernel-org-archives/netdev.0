From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Mon, 17 Jan 2005 10:02:16 -0800
Message-ID: <20050117100216.22767083@dxpl.pdx.osdl.net>
References: <20050117152312.GC26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050117152312.GC26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 17 Jan 2005 16:23:12 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> While collecting performance numbers for the ematch changes
> I realized that the throughput of changes per second is
> almost only limited by the cost of starting the tc binary
> over and over. In order to improve this, batching of commands
> is required. My plan to do so is quite simple, introduce
> a new flag -f which puts tc into batched mode and makes
> it read commands from stdin. A bison based parser splits
> things into tokens, the grammer would be quite easy:
> 
> INPUT ::= { /* empty */ | CMDS }
> CMDS  ::= { CMD | CMD ';' CMDS }
> CMD   ::= ARGS
> ARGS  ::= { STRING | STRING ARGS }
> 
> The lexical part can be made to ignore c-syle and
> shell-style comments, i.e.
> 
> ---
> #!/sbin/tc -f
> 
> /* some comments here */
> qdisc add ..
> class ...
> 
> # shell like comments also possible
> filter add ... basic match ...
> ---
> 
> Of course this loses ability to use shell features like
> variables and loops and it's probably not worth trying
> to emulate things. One can always generate these tc scripts
> with the help of other tools like m4, you name it.
> 
> This could also be applied to ip of course.
> 
> Thoughts?

The tc command line processing might leak memory now, or suffer
from expected variable initialization issues.  You may want to run it
with valgrind or other tools to check for that.

-- 
Stephen Hemminger	<shemminger@osdl.org>
