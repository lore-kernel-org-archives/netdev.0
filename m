From: "J.A. Magallon" <jamagallon@able.es>
Subject: Re: [RFC][PATCH] net drivers and cache alignment
Date: Sun, 8 Dec 2002 00:52:55 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021207235255.GA3754@werewolf.able.es>
References: <3DF2781D.3030209@pobox.com> <20021207.144004.45605764.davem@redhat.com> <3DF27EE7.4010508@pobox.com> <3DF2844C.F9216283@digeo.com> <20021207233745.GE3183@werewolf.able.es> <3DF28811.F6580BA6@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Cc: "J.A. Magallon" <jamagallon@able.es>, Jeff Garzik <jgarzik@pobox.com>,
   "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@digeo.com>
Content-Disposition: inline
In-Reply-To: <3DF28811.F6580BA6@digeo.com>; from akpm@digeo.com on Sun, Dec 08, 2002 at 00:45:21 +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On 2002.12.08 Andrew Morton wrote:
>"J.A. Magallon" wrote:
>> 
>> #define __cacheline_start   struct { } ____cacheline_aligned;
>
>That will generate a warning on faster^Wolder versions of gcc.
>
>mnm:/home/akpm> gcc t2.c
>t2.c:11: warning: unnamed struct/union that defines no instances
>t2.c:15: warning: unnamed struct/union that defines no instances
>mnm:/home/akpm> gcc -v 
>Reading specs from /usr/local/lib/gcc-lib/i686-pc-linux-gnu/2.95.3/specs
>gcc version 2.95.3 20010315 (release)
>

And how 'bout this (do not have any gcc oldie available to test):

#define __cacheline_start   union { int :0; } ____cacheline_aligned;

It passes gcc-3.2 -Wall...
I think it's nicer to insert __c_s than to go field by field marking
them...

-- 
J.A. Magallon <jamagallon@able.es>      \                 Software is like sex:
werewolf.able.es                         \           It's better when it's free
Mandrake Linux release 9.1 (Cooker) for i586
Linux 2.4.20-jam1 (gcc 3.2 (Mandrake Linux 9.1 3.2-4mdk))
