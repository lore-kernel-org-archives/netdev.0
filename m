From: chas williams <chas@cmf.nrl.navy.mil>
Subject: forcing bottom half to a specific processor on numa
Date: Fri, 29 Aug 2003 11:49:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308291549.h7TFngl5014364@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

for my network card (its an atm card but that really doesnt matter in
this case since the work done is fundamentally very similar) on a numa
machine i would prefer that the bottom half processing happen on
a processor that is 'local' (or atleast closer) to the card.  primarily,
so that any copies to/from the card and buffers that might allocated
be given to card come from the memory on the processor to prevent
undo traffic on the machine's interconnect.  my particular h/w is the
sn2.  i do something like the following to force the tasklet be 
scheduled on the 'local' processor:

	...
	he_dev->cnode = nasid_to_cnodeid(NASID_GET(he_dev->membase));
	...

__tasklet_schedule(void *data)
{
        struct he_dev *he_dev = (struct he_dev *) data;
        tasklet_schedule(&he_dev->tasklet);
}

he_irq_handler()
{
...
	smp_call_function_single(he_dev->cnode, __tasklet_schedule, he_dev, 0, 0);
...
}

is there a reason i shouldnt do this?  is there a better way?
