From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: ipt_physdev.c alignment problems on parisc64
Date: Tue, 2 Sep 2003 11:30:50 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902143050.GC3398@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netfilter-devel@lists.netfilter.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The 1.786.1.54 changeset (i.e. the initial ipt_physdev.c one 8) created this
alignment problems on parisc64:

tmp.stdout.allegro.31506.s: Assembler messages:
tmp.stdout.allegro.31506.s:97: Error: Field not properly aligned [8] (18).
tmp.stdout.allegro.31506.s:97: Error: Invalid operands
tmp.stdout.allegro.31506.s:125: Error: Field not properly aligned [8] (34).
tmp.stdout.allegro.31506.s:125: Error: Invalid operands
tmp.stdout.allegro.31506.s:129: Error: Field not properly aligned [8] (50).
tmp.stdout.allegro.31506.s:129: Error: Invalid operands

I got this nailed to the match function, on these lines:

        for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
                ret |= (((const unsigned long *)indev)[i]
                        ^ ((const unsigned long *)info->physindev)[i])
                        & ((const unsigned long *)info->in_mask)[i];
        }

and

        for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
                ret |= (((const unsigned long *)outdev)[i]
                        ^ ((const unsigned long *)info->physoutdev)[i])
                        & ((const unsigned long *)info->out_mask)[i];
        }


Reading specs from /opt/palinux/lib/gcc-lib/hppa64-linux/3.0.4/specs
Configured with: ../../gcc-3.0-3.0.4ds3/src/configure --host=hppa-linux --build=hppa-linux --target=hppa64-linux --disable-shared --disable-nls --enable-languages=c --prefix=/opt/palinux
Thread model: single
gcc version 3.0.4
acme@allegro:~/bk/scsi-2.6$

- Arnaldo
