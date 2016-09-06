From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] bonding: Prevent deletion of a bond, or the last slave
 from a bond, with active usage.
Date: Tue, 6 Sep 2016 16:59:16 +0200
Message-ID: <20160906145916.GI1692@nanopsycho>
References: <1473154470-15087-1-git-send-email-jasminder.kaur@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        vasundhara.gurunath@hpe.com, paulose.kuriakose.arackal@hpe.com
To: "Kaur, Jasminder" <jasminder.kaur@hpe.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473154470-15087-1-git-send-email-jasminder.kaur@hpe.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Sep 06, 2016 at 11:34:30AM CEST, jasminder.kaur@hpe.com wrote:
>From: "Kaur, Jasminder" <jasminder.kaur@hpe.com>
>
>If a bond is in use such as with IP address configured, removing it
>can result in application disruptions. If bond is used for cluster
>communication or network file system interfaces, removing it can cause
>system down time.
>
>An additional write option “?-” is added to sysfs bond interfaces as
>below, in order to prevent accidental deletions while bond is in use.
>In the absence of any usage, the below option proceeds with bond deletion.
>“ echo "?-bondX" > /sys/class/net/bonding_masters “ .
>If usage is detected such as an IP address configured, deletion is
>prevented with appropriate message logged to syslog.
>
>In the absence of any usage, the below option proceeds with deletion of
>slaves from a bond.
>“ echo "?-enoX" > /sys/class/net/bondX/bonding/slaves “ .
>If usage is detected such as an IP address configured on bond, deletion
>is prevented if the last slave is being removed from bond.
>An appropriate message is logged to syslog.

NACK

sysfs bonding iface should die in peace, don't poke in it.

Either fix you application or fix you configuration flow. Don't do this
in kernel.
