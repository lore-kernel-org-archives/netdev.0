From: Rahul Hari <rahulhsaxena@gmail.com>
Subject: testing techniques to confirm the effectiveness of changes made to sch_gred.c
Date: Sat, 11 Jun 2005 06:09:42 +0530
Message-ID: <4532f3170506101739702e31ad@mail.gmail.com>
Reply-To: rahul.hari@cse06.itbhu.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, netdev@vger.kernel.org, lartc-request@mailman.ds9a.nl,
        diffserv-general@lists.sourceforge.net, linux.kernel@googlegroups.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I have made some changes to the file sch_gred.c to modify the GRED
queueing discipline to support the following features:
1) The first virtual queue should get absolute priority while
dequeueing (not caring if the others get starved)
2) While in equalise mode and with RIO mode enabled, the packets in
the first virtual queue should not be counted for calculating the
qave.

I want to confirm if the changes made by me are really effective. I
would be grateful if someone could let me know about any testing
techniques that can be followed for confirming that the changes are
really effective.

It would be great if someone could also let me know if the logic that
I have applied to effect these changes is correct.

My logic is as follows:
1) Since the  process deals with dequeueing, i have to make changes to
gred_dequeue only. If t->tab[0] != 0 then  we dequeue the packet
otherwise do not dequeue it.

2)  
if (t->eqp && t->grio) {

         for (i=0;i<t->DPs;i++) {
			if ((!t->tab[i]) || (i==q->DP) || (i==0))	
				continue; 
				
			if ((t->tab[i] != q) && (PSCHED_IS_PASTPERFECT(t->tab[i]->qidlestart)))
				qave +=t->tab[i]->qave;
		     }



Regards,
Rahul

-- 
----------------------
"The fear you let build up in your mind is worse than the situation
that actually exists"
from "who moved my cheese"
---------------------------------------------------------------------------------
Rahul Hari
Senior Under Grad. Student,
Department of CSE,
ITBHU,
Varanasi.
Ph: +91-9845347020
rahul.hari@cse06.itbhu.org
------------------------------------------------------------------------------------------
