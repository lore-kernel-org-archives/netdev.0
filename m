From: Andi Kleen <ak@suse.de>
Subject: Re: packet re-ordering on SMP machines.
Date: Tue, 27 Aug 2002 13:12:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020827131227.A16565@wotan.suse.de>
References: <009701c24d54$d27304a0$f1fa010a@weixl> <Pine.GSO.4.30.0208270633130.6895-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: "Xiaoliang (David) Wei" <weixl@caltech.edu>,
   Ben Greear <greearb@candelatech.com>, Cheng Jin <chengjin@cs.caltech.edu>,
   Cheng Hu <chenghu@cs.caltech.edu>, Steven Low <slow@cs.caltech.edu>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0208270633130.6895-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Tue, Aug 27, 2002 at 06:59:33AM -0400, jamal wrote:
> 
> 
> 
> On Mon, 26 Aug 2002, Xiaoliang (David) Wei wrote:
> 
> > Hi Ben and Jamal,
> >        Are you guys sure that getdayoftime per packet is a big overhead on
> > Gbps connection?
> 
> We may be talking about different things;
> I am talking about do_gettimeofday -- which is very expensive.
> Anyone who has time could look at improving that. It is run per incoming
> packet.

That is because of the lock it takes. Locks are always slow.

Older kernels used gettimeoffset which ran without lock, but that was
changed because in some very obscure cases it could cause non monotonous
timestamps when the user turns on timestamp receiving to user space
(kernel protocols do not care)

Possibilities: 

- Ignore the problem and switch back to gettimeoffset again
- Switch to gettimeoffset but add some correction step for the unlikely
case that someone wants the timestamp from user space
(would be my prefered solution) 
- Implement lockless gettimeofday like x86-64 or sparc
(good one too, but likely slower than last) 


-Andi
