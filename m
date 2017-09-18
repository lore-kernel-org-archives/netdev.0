From: josef@toxicpanda.com
Subject: [PATCH 0/3] fix reuseaddr regression
Date: Mon, 18 Sep 2017 12:28:54 -0400
Message-ID: <1505752137-15522-1-git-send-email-jbacik@fb.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, crobinso@redhat.com,
        labbott@redhat.com, kernel-team@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I introduced a regression when reworking the fastreuse port stuff that allows
bind conflicts to occur once a reuseaddr socket successfully opens on an
existing tb.  The root cause is I reversed an if statement which caused us to
set the tb as if there were no owners on the socket if there were, which
obviously is not correct.

Dave I have follow up patches that will add a selftest for this case and I ran
the other reuseport related tests as well.  These need to go in pretty quickly
as it breaks kvm, I've marked them for stable.  Sorry for the regression,

Josef
