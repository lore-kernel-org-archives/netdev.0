From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Bug in qeth in 2.6
Date: Wed, 3 Sep 2003 14:54:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903145444.I27572@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, zaitcev@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: cohuck@de.ibm.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This code is obviously broken in case several cards are present,
look what happens to ``result''.

devices/s390/net/qeth.c:

static int
qeth_verify_dev(struct net_device *dev)
{
        struct qeth_card *tmp;
        int result = 0;
                                                                                
        read_lock(&list_lock);
        tmp = firstcard;
        for (; tmp && (!result); tmp = tmp->next) {
                if (atomic_read(&tmp->shutdown_phase))
                        continue;
                result = (dev == tmp->dev)?
                        QETH_VERIFY_IS_REAL_DEV:__qeth_verify_dev_vlan(dev, tmp);
        }
        read_unlock(&list_lock);
        return result;
}

Someone got seriously carried away with cleanups.
I have to say, I'm disappointed. The original qeth in 2.4
had poor C style, but it was a mistake to run amok adding
spaces. The diff between 2.4 and 2.6 is too hard to read,
even with -b. Now I have to review whole darn thing line by line.
Oh woe!

-- Pete
