From: Adrian Bunk <bunk@stusta.de>
Subject: bcm43xx_sysfs.c: strange code
Date: Tue, 4 Apr 2006 20:44:35 +0200
Message-ID: <20060404184435.GV6529@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750796AbWDDSoi@vger.kernel.org>
To: Michael Buesch <mbuesch@freenet.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker spotted the following strange code:

<--  snip  -->

static ssize_t bcm43xx_attr_interfmode_show(struct device *dev,
                                            struct device_attribute *attr,
                                            char *buf)
{
...
        err = 0;

        bcm43xx_unlock(bcm, flags);

        return err ? err : count;

}
...
static ssize_t bcm43xx_attr_preamble_show(struct device *dev,
                                          struct device_attribute *attr,
                                          char *buf)
{
...
        err = 0;
        bcm43xx_unlock(bcm, flags);

        return err ? err : count;
}
...
static ssize_t bcm43xx_attr_preamble_store(struct device *dev,
                                           struct device_attribute *attr,
                                           const char *buf, size_t count)
{
...
        err = 0;
        bcm43xx_unlock(bcm, flags);

        return err ? err : count;
}
...

<--  snip  -->

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
