From: "Zhenyu Wu" <y030729@njupt.edu.cn>
Subject: Something on CBQ!
Date: Fri, 07 Jan 2005 18:00:53 +0800
Message-ID: <305092053.32587@njupt.edu.cn>
Reply-To: "Zhenyu Wu" <y030729@njupt.edu.cn>
Content-Type: text/plain
Cc: lartc@mailman.ds9a.nl, imipak@yahoo.com
Return-path: <lartc-admin@mailman.ds9a.nl>
To: netdev@oss.sgi.com
Sender: lartc-admin@mailman.ds9a.nl
Errors-To: lartc-admin@mailman.ds9a.nl
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Subscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
List-Unsubscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc/>
List-Id: netdev.vger.kernel.org

Hello, 

I think I have misundertood the relationship between cbq and the queue (such as
Red) attached to 
it. This is my latest opion, please give me some advice on it:

At beginning, I thought that a packet will be firstly classified by the CBQ where
it will 
find the proper class it belongs to. Then the packet enters the queue attached to
that class.
At last, the packet is scheduled in that queue, and put into the link. But now, I
find it is 
wrong. I have read the source code on CBQ again, especially the part-cbq_dequeue,
I think
that at first the CBQ will find the active class and their priority. Then in the
function 
cbq_dequeue_prio, the algorithm WRR will be used to schedule the packet. At first,
it find a class,
then, this skb = cl->q->dequeue(cl->q) maybe very important, I think "cl->q" is
the queue 
attached to the class "cl". So, the packet in the different queue is scheduled and
put into 
the link. 

Another issue is that a scheduling algorithm WRR is used here, But i think it is
not the best
one, So can we modify here and add a new scheduling algorithm as we expected?

What about your opions?

Best,



_______________________________________________
LARTC mailing list / LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
